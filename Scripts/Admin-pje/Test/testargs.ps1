cls

function testargs{

	if ($args.Count -eq 0)
	{
		[String]$ComputerName = ""
	}

	elseif ($args.Count -eq 1)
	{
		[String]$ComputerName = ""
		[string]$RedistributeActiveDatabases = $args[0]
	}
	else{
		
		[String]$ComputerName = $args[0]
		[String]$MoveActiveMailboxDatabase = $args[1]
	}
	
	$ComputerName
	$RedistributeActiveDatabases
	$MoveActiveMailboxDatabase
}