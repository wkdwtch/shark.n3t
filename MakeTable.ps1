$namesFile = "names.txt"
$currentDir = (Get-Item .).FullName
$entries = [System.IO.File]::ReadAllLines((Join-Path $currentDir $namesFile), [System.Text.Encoding]::UTF8) | Select-Object -Unique

$html = @"
<input type="text" id="myInput" onkeyup="searchTable()" placeholder="Search for names..." style="width:100%; padding:12px; margin-bottom:12px; border:1px solid #ddd; border-radius:4px;">
<table id="myTable" style="width:100%; border-collapse:collapse; font-family:sans-serif;">
  <tr style="background-color:#f2f2f2; text-align:left;">
    <th style="padding:12px; border:1px solid #ddd;">Name / Directory Item</th>
    <th style="padding:12px; border:1px solid #ddd;">Links</th>
  </tr>
"@

foreach ($line in $entries) {
    $name = $line.Trim()
    if ($name) {
        $encoded = [Uri]::EscapeDataString($name)
        $googleUrl = "https://google.com"
        $ytUrl = "https://youtube.com"
        
        $html += "<tr>"
        $html += "<td style='padding:12px; border:1px solid #ddd; font-weight:bold;'>$name</td>"
        $html += "<td style='padding:12px; border:1px solid #ddd;'><a href='$googleUrl' target='_blank' style='margin-right:15px; color:#4285F4; text-decoration:none;'>Google Search</a> <a href='$ytUrl' target='_blank' style='color:#FF0000; text-decoration:none;'>YouTube Search</a></td>"
        $html += "</tr>"
    }
}

$html += @"
</table>
<script>
function searchTable() {
  var input, filter, table, tr, td, i, txtValue;
  input = document.getElementById("myInput");
  filter = input.value.toUpperCase();
  table = document.getElementById("myTable");
  tr = table.getElementsByTagName("tr");
  for (i = 1; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[0];
    if (td) {
      txtValue = td.textContent || td.innerText;
      if (txtValue.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }
  }
}
</script>
"@

[System.IO.File]::WriteAllText((Join-Path $currentDir "Blogger_Table.txt"), $html, [System.Text.Encoding]::UTF8)
Write-Host "Table code generated in Blogger_Table.txt!" -ForegroundColor Green