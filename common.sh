# Funcoes comuns dos CGI. Uso: . /usr/lib/liveos/common.sh
json_head() { printf 'Content-Type: application/json\r\nCache-Control: no-store\r\n\r\n'; }

# exige o token do boot (parametro t=...)
guard() {
	TOKEN=$(cat /run/liveos/token 2>/dev/null)
	if [ -z "$TOKEN" ] || ! echo "&$QUERY_STRING&" | grep -q "&t=$TOKEN&"; then
		printf 'Status: 403 Forbidden\r\nContent-Type: text/plain\r\n\r\nnegado'
		exit 0
	fi
}

wifi_if() { cat /run/liveos/wifi-if 2>/dev/null; }

# qget nome -> valor decodificado do parametro
qget() {
	V=$(echo "$QUERY_STRING" | tr '&' '\n' | sed -n "s/^$1=//p" | head -n1)
	httpd -d "$V"
}
