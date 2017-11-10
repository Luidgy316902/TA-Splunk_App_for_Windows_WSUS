function Merge-Object {
  param(
    $Base,
    $Additional
  )

  foreach ($Property in $($Additional | Get-Member -Type Property, NoteProperty)) {
    $Base | Add-Member -MemberType NoteProperty -Name $Property.Name `
      -Value $Additional.$($Property.Name) -ErrorAction SilentlyContinue
  }
  return $Base
}
