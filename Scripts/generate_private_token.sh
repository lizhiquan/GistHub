if [ -f .env ]; then
	export $(cat .env | grep -v '#' | awk '/=/ {print $0}')

	touch GitHubPrivateKey.swift
	echo "// Do not edit\n// Generated by Scripts/generate_private_token.sh\n\n/// Personal access token that used to authenticate API\npublic let PRIVATE_TOKEN = $PRIVATE_TOKEN" >> GitHubPrivateKey.swift

	mv GitHubPrivateKey.swift GistHub/Networking

	echo "Generated GitHubPrivateKey.swift inside GistHub/Networking"
else
	echo "No .env file found"
fi