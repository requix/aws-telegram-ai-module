
# AWS Telegram AI Module

## Project Description

The AWS Telegram AI Module is a project designed to seamlessly integrate an AI assistant with a Telegram chatbot. Utilizing the capabilities of the new OpenAI API, this project enables users to interact with an advanced AI model directly through Telegram. The module is particularly useful for creating specialized assistants, such as a math tutor, language teacher, or general-purpose chatbot.

## Requirements

- AWS Account
- Telegram Bot Token
- OpenAI API Key
- Terraform installed on your local machine

## Deployment Instructions

1. **AWS Setup:**
   - Ensure you have an active AWS account.
   - Configure AWS CLI with your credentials.

2. **Telegram Bot Setup:**
   - Create a new bot on Telegram via BotFather.
   - Note down the generated Bot Token.

3. **OpenAI API Key:**
   - Obtain an API key from OpenAI by creating an account and following their access guidelines.

4. **Local Environment Setup:**
   - Install Terraform on your local machine.
   - Clone the repository: `git clone https://github.com/requix/aws-telegram-ai-module`

5. **Terraform Initialization:**
   - Navigate to the cloned directory.
   - Run `terraform init` to initialize Terraform.

6. **Terraform Apply:**
   - Modify the `terraform.tfvars` file with your specific configuration (Bot Token, OpenAI API Key, etc.).
   - Execute `terraform apply` to deploy the module to your AWS account.

## Usage Guide

Once deployed, you can interact with your AI assistant via the Telegram bot. Customize the assistant's behavior by modifying the parameters in the Terraform configuration file.

### Interacting with the Bot
- Start a conversation with your Telegram bot.
- Type your queries or commands.
- The AI assistant will respond based on its configured capabilities.

### Modifying Assistant Behavior
- Edit the `terraform.tfvars` file to change the assistant's characteristics.
- Re-run `terraform apply` to update the deployment.

## Example

Here's an example configuration for setting up a math assistant:

```hcl
module "math_assistant" {
  source  = "git::https://github.com/requix/aws-telegram-ai-module"
  
  app_name = "telegram-math-assistant"
  allowed_users_ids = [1111111111, 2222222222]
  assistant_name = "Math Tutor"
  assistant_instructions = "You are a personal math tutor. Write and run code to answer math questions."
  assistant_model = "gpt-4-1106-preview"
}
```

In this configuration, a Telegram bot named "Math Tutor" is set up, limited to specific user IDs, and utilizes the GPT-4 model to assist with math-related queries.
