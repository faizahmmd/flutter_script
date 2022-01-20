$myJson = Get-Content .\test.json -Raw | ConvertFrom-Json
$appname = $myJson.name
$packagename = $myJson.package_name
$description = $myJson.description
$templateappname = $myJson.template_app_name
$templateappdescription = $myJson.template_app_description
$createprojectfromgitrepotemplate = $myJson.create_project_from_git_repo_template
$template = $myJson.template_git_url
$templatefolderpath = $myJson.template_folder_path
$templatefoldername = $myJson.template_folder_name
$gitinitilize = $myJson.git_initialize
$projectgiturl = $myJson.project_git_url
$gituseremail = $myJson.git_user_email
$gitusername = $myJson.git_user_name
$location = $myJson.project_location
$dependencies = $myJson.dependencies
$devdependencies = $myJson.dev_dependencies
Set-Location $location
if($createprojectfromgitrepotemplate){
    $templatelocation = $location
    git clone $template
    Set-Location $templateappname
}else{
    $templatelocation = $templatefolderpath
    $templateappname = $templatefoldername
    Set-Location $templatefolderpath\$templateappname
}
$pubspecfiledata = (Get-Content ".\pubspec.yaml" -Raw) -replace "name: $($templateappname)" ,"name: $($appname)" -replace "description: $($templateappdescription)","description: $($description)"
Set-Content -Path '.\pubspec.yaml' -Value $pubspecfiledata
Set-Location $location
flutter create  -a kotlin -i swift  --description $description --org $packagename $appname
Remove-Item -Path $location\$appname\pubspec.yaml -Recurse -Force
Copy-Item $templatelocation\$templateappname\pubspec.yaml $location\$appname -Recurse -Force
Copy-Item $templatelocation\$templateappname\assets $location\$appname -Recurse -Force
Remove-Item -Path $location\$appname\lib -Recurse -Force
Copy-Item $templatelocation\$templateappname\lib $location\$appname -Recurse -Force
Remove-Item $location\$appname\*.git
Remove-Item -Path $templatelocation\$templateappname -Recurse -Force
Set-Location $location\$appname
Get-ChildItem -Path $location\$appname -Recurse *.dart | Foreach-Object{
    $filedata = (Get-Content -Path $_.FullName -Raw) -replace "$($templateappname)" ,"$($appname)"
    Set-Content -Path $_.FullName -Value $filedata
}
flutter clean
for($i = 0; $i -lt $dependencies.length; $i++){ flutter pub add $dependencies[$i] }
for($i = 0; $i -lt $devdependencies.length; $i++){ flutter pub add -d $devdependencies[$i] }
flutter pub get
if($gitinitilize){
  git config --global user.email $gituseremail |
  git config --global user.name $gitusername |
  git init |
  git add --all |
  git commit -m "first commit" |
  git remote add origin $projectgiturl |
  git push -u origin master
}
code .