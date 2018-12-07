
param(
 
	  
		[string] $pat,
        [String] $sourceBranch,
        [String] $repositoryId,
        [String] $name,
        [String] $genre,
        [String] $project,
        [String] $org,
        [String] $releaseId,
        [String] $status,
        [String] $description
)


Write-Host "PAT $pat"
Write-Host "Source Branch $sourceBranch"
Write-Host "Status Name $name"
Write-Host "Status genre $genre"
Write-Host "Project $project"
Write-Host "Org $org"
Write-Host "Release ID $releaseId"
Write-Host "Status $status"
Write-Host "Descritpion $description"

#$(Release.Artifacts.vs2017.SourceBranch)

$pr= $sourceBranch -split '/'
$pullRequestId=$pr[2]
echo "the pull request id is $prid"
 
 
Function UpdateStatus($org, $prj, $repositoryId, $pullRequestId, $personalAccessToken, $body){
	$url = "https://dev.azure.com/$org/$prj/_apis/git/repositories/$repositoryId/pullRequests/$pullRequestId/statuses?api-version=4.1-preview.1"
	$headers= @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)")) }
    Write-Host $url
	$response= (Invoke-RestMethod -Uri $url -headers $headers -Method Post -Body $body -ContentType "application/json") 
	return  $response 

}



Function GetBody($name,$genre, $description, $status, $releaseId, $org, $prj) {

 $body = @{
        "iterationId" = 1;
        "state"= "$status";
        "description"= "$description";
        "context" = @{
            "name"= "$name";
            "genre"= "$genre";
        }

        "targetUrl" = "https://$org.visualstudio.com/$prg/_releaseProgress?_a=release-pipeline-progress&releaseId=$releaseId";
    }| ConvertTo-Json

    Write-Host "JSON body: $body"
    return $body
}

$body = GetBody -org $org -prj $project -name $name -genre $genre -description $description -status $status -releaseId $releaseId

$ret = UpdateStatus -body $body -org $org -prj $project -repositoryId $repositoryId  -personalAccessToken $pat  -pullRequestId $pullRequestId  
Write-Host $ret
 