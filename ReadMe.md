
https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings

# Install Azure Functions Core Tools
https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=v4%2Clinux%2Ccsharp%2Cportal%2Cbash#v2

# Install Python 3.9
https://linuxize.com/post/how-to-install-python-3-9-on-ubuntu-20-04/
sudo apt-get install python3-venv

# Create Function
python -m venv .venv
source .venv/bin/activate

func init serverless --python
func new --name http --template "HTTP trigger" --authlevel "anonymous"
func new --name queue --template "Azure Service Bus Queue trigger"

# Fetch Configuration
func azure functionapp fetch-app-settings '<function-name>' --output-file local.settings.json

# References
https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=asgi%2Capplication-level#folder-structure
