function toggle-list-sep
{
  $path = "hkcu:\Control Panel\International"
  $key = "sList"
  
  $cur_sep = (Get-ItemProperty -path $path -name $key).$key
  
  if ($args.Length -gt 0) { $value = $args[0] }
  elseif ($cur_sep -eq ",") { $value = "|" } 
  else { $value = "," }
  
  Set-ItemProperty -path $path -name $key -Value $value -type string
  $new_sep = (Get-ItemProperty -path $path -name $key).$key
  
  Write-Output "Changed $path.$key from '$cur_sep' to '$new_sep'"
}
