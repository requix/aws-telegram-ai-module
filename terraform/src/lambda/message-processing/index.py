"""
This function implements a Telegram bot integrated with OpenAI service.

The core functionality involves a Telegram bot designed to interact with users,
processing their messages and responding accordingly. Integrated with OpenAI's
API, the bot uses advanced AI models for generating responses.

The function also manages DynamoDB interactions for storing and retrieving
data like user IDs, assistant configurations, and thread info, ensuring smooth
conversation flows with OpenAI API.
"""


import json
import logging
import os
from aws_lambda_powertools import Tracer, Metrics, Logger

import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError
import telebot
from openai import OpenAI


tracer = Tracer()
metrics = Metrics()
logger = Logger()

ssm = boto3.client('ssm')

TELEGRAM_TOKEN_PARAM_NAME = os.getenv('telegram')
OPENAI_TOKEN_PARAM_NAME = os.getenv('openai')

TELEGRAM_TOKEN = ssm.get_parameter(
    Name=TELEGRAM_TOKEN_PARAM_NAME, WithDecryption=True
)['Parameter']['Value']
bot = telebot.TeleBot(TELEGRAM_TOKEN, threaded=False)

OPENAI_TOKEN = ssm.get_parameter(
    Name=OPENAI_TOKEN_PARAM_NAME, WithDecryption=True
)['Parameter']['Value']
openai_client = OpenAI(api_key=OPENAI_TOKEN)

allowed_users_ids = os.getenv('allowed_users_ids')
ALLOWED_USERS = list(map(int, allowed_users_ids.split(',')))

dynamodb_client = boto3.client('dynamodb')
dynamodb_resource = boto3.resource('dynamodb')

ASSISTANT_TABLE_NAME = os.getenv('assistant_table_name')
assistant_table = dynamodb_resource.Table(ASSISTANT_TABLE_NAME)
THREADS_TABLE_NAME = os.getenv('threads_table_name')
threads_table = dynamodb_resource.Table(THREADS_TABLE_NAME)


@tracer.capture_lambda_handler
@metrics.log_metrics
@logger.inject_lambda_context
def handler(event, _context):
    """
    This is the main handler function that will be invoked by AWS Lambda.
    """
    process_event(event)
    return {
        "statusCode": 200,
        "body": "Event processed successfully!"
    }


@tracer.capture_method(capture_response=False)
def process_event(event):
    """
    Parse the event and process it using the bot's update handler.
    """
    logger.info("Event: %s", event)
    request_body_dict = json.loads(event['Records'][0]['body'])
    update = telebot.types.Update.de_json(request_body_dict)
    bot.process_new_updates([update])


@tracer.capture_method(capture_response=False)
def escape_markdown(string: str) -> str:
    """
    Escape markdown characters in a string to prevent formatting issues.
    """
    escape_chars = [
        "_", "*", "[", "]", "(", ")", "~", ">", "#",
        "+", "-", "=", "|", "{", "}", ".", "!", ","
    ]
    for char in escape_chars:
        string = string.replace(char, f"\\{char}")
    return string


@tracer.capture_method(capture_response=False)
def ask_openai_threads(chat_id, question):
    """
    Send a question to OpenAI and return the response for the specified chat_id
    """
    try:
        assistant_id = get_stored_assistant_id()
        if not assistant_id:
            assistant_id = create_assistant()
            save_assistant(assistant_id)

        thread_id = get_stored_thread_id(chat_id)
        if not thread_id:
            thread = openai_client.beta.threads.create()
            thread_id = thread.id
            save_thread(chat_id, thread_id, "Test name")

        openai_client.beta.threads.messages.create(
            thread_id=thread_id, role="user", content=question)

        run = openai_client.beta.threads.runs.create(
            thread_id=thread_id, assistant_id=assistant_id)

        while True:
            run_status = openai_client.beta.threads.runs.retrieve(
                thread_id=thread_id, run_id=run.id)
            if run_status.status == 'completed':
                break

        messages = openai_client.beta.threads.messages.list(
            thread_id=thread_id)
        logger.info("Messages: %s", messages)

        assistant_message = next(
            (m for m in messages.data if m.role == 'assistant'), None)
        if assistant_message:
            assistant_response = assistant_message.content[0].text.value
        else:
            assistant_response = "No response from the assistant."
        return assistant_response
    except ClientError as e:
        logging.error("ClientError occurred: %s", e)
        return "Error with the client request. Please try again later."


@tracer.capture_method(capture_response=False)
@bot.message_handler(func=lambda message: message.chat.id not in ALLOWED_USERS)
def decline_strangers(message):
    """
    Reply to unauthorized users who try to use the bot.
    """
    response_message = (
        f"You are not allowed to use this bot\n"
        f"Ask admin to add your user id: {message.chat.id}"
    )
    bot.reply_to(message, response_message)


@tracer.capture_method(capture_response=False)
@bot.message_handler(commands=['help', 'start'])
def send_welcome(message):
    """
    Send a welcome message in response to 'help' or 'start' commands.
    """
    bot.reply_to(message, ("Hi there, I am EchoBot.\n"
                           "I am here to echo your kind words back to you."))


@tracer.capture_method(capture_response=False)
@bot.message_handler(func=lambda message: True, content_types=['text'])
def echo_message(message):
    """
    Process and respond to user messages using OpenAI threads.
    """
    user_input = message.text.strip()
    bot.send_chat_action(chat_id=message.chat.id, action="typing")

    answer = ask_openai_threads(message.chat.id, user_input)

    bot.reply_to(
        message=message,
        text=escape_markdown(answer),
        parse_mode="MarkdownV2"
    )


@tracer.capture_method(capture_response=False)
def create_assistant():
    """
    Create an Assistant with the beta endpoint
    """
    try:
        assistant_tools = []
        assistant_name = os.getenv('assistant_name')
        assistant_instructions = os.getenv('assistant_instructions')
        assistant_model = os.getenv('assistant_model')

        if bool(os.getenv('enable_code_interpreter')):
            assistant_tools = [{"type": "code_interpreter"}]

        assistant_response = openai_client.beta.assistants.create(
            name=assistant_name,
            instructions=assistant_instructions,
            tools=assistant_tools,
            model=assistant_model
        )
        return assistant_response.id
    except Exception as e:
        logging.error("Error occurs while creating an Assistant: %s", e)
        raise


@tracer.capture_method(capture_response=False)
def save_assistant(assistant_id):
    """
    Save assistant_id to the DynamoDB table
    """
    try:
        response = dynamodb_client.put_item(
            TableName=ASSISTANT_TABLE_NAME,
            Item={'assistant_id': {'S': assistant_id}}
        )
        return response
    except ClientError as e:
        logging.error("Error: %s", e.response['Error']['Message'])
        raise


@tracer.capture_method(capture_response=False)
def get_stored_assistant_id():
    """
    Get stored assistant_id.
    """
    try:
        response = assistant_table.scan()
        logger.info("Stored Assistant: %s", response)

        if response['Items']:
            return response['Items'][0]['assistant_id']

        return None

    except ClientError as e:
        logging.error("Error: %s", e.response['Error']['Message'])
        raise


@tracer.capture_method(capture_response=False)
def save_thread(chat_id, thread_id, thread_name):
    """
    Save thread_id to the DynamoDB table.
    """
    try:
        response = dynamodb_client.put_item(
            TableName=THREADS_TABLE_NAME,
            Item={
                'chat_id': {'N': str(chat_id)},
                'thread_id': {'S': thread_id},
                'thread_name': {'S': thread_name},
                'thread_status': {'S': 'ACTIVE'}
            }
        )
        return response
    except ClientError as e:
        logging.error("Error: %s", e.response['Error']['Message'])
        raise


@tracer.capture_method(capture_response=False)
def get_stored_thread_id(chat_id):
    """
    Get stored thread_id for the current chat.
    """
    try:
        response = threads_table.query(
            IndexName='UserStatusIndex',
            KeyConditionExpression=Key('chat_id').eq(chat_id)
            & Key('thread_status').eq('ACTIVE'),
            Limit=1
        )
        logger.info("Stored Active Threads: %s", response)
        return response['Items'][0]['thread_id'] if response['Items'] else None
    except ClientError as e:
        logging.error("Error: %s", e.response['Error']['Message'])
        raise
