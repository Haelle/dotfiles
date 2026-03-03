function __jwt_decode_part --description 'Decode a base64url JWT part'
    set -l input $argv[1]
    # Handle base64url encoding (replace - with +, _ with /)
    set -l data (string replace -a '-' '+' $input | string replace -a '_' '/')
    # Add padding if needed
    set -l mod (math (string length $data)" % 4")
    if test $mod -eq 2
        set data $data"=="
    else if test $mod -eq 3
        set data $data"="
    end
    echo $data | base64 -d 2>/dev/null | jq . 2>/dev/null; or echo $data | base64 -d 2>/dev/null
end

function jwt --description 'Decode a JWT token (header + payload)'
    if test (count $argv) -eq 0
        echo "Usage: jwt <token>"
        return 1
    end

    set -l parts (string split '.' $argv[1])
    if test (count $parts) -lt 2
        echo "Invalid JWT format"
        return 1
    end

    echo "=== Header ==="
    __jwt_decode_part $parts[1]
    echo ""
    echo "=== Payload ==="
    __jwt_decode_part $parts[2]
end

function jwth --description 'Decode JWT header only'
    if test (count $argv) -eq 0
        echo "Usage: jwth <token>"
        return 1
    end
    set -l parts (string split '.' $argv[1])
    __jwt_decode_part $parts[1]
end

function jwtp --description 'Decode JWT payload only'
    if test (count $argv) -eq 0
        echo "Usage: jwtp <token>"
        return 1
    end
    set -l parts (string split '.' $argv[1])
    __jwt_decode_part $parts[2]
end
