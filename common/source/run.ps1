using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$content = (invoke-webrequest -uri https://ipinfo.io/json).Content

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $content
})
