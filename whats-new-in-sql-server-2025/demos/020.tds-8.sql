SELECT 
	net_transport,
	protocol_type, 
	protocol_version,
	CONVERT(binary(4),protocol_version) 
FROM sys.dm_exec_connections;
