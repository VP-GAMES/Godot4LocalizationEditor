extends Control

var ctx = HMACContext.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	var key = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
	var kSecret = ("AWS4" + key).to_utf8_buffer()
	
	var date_stamp = '20221025'
	var region = 'us-east-1'
	var service = 'translate'
	var secret_key = "9jMD4qEAvBCyavlOAedB/KstqMKZjX8S9XuN8vpt"
	var signing_key = getSignatureKey(secret_key, date_stamp, region, service)

func getSignatureKey(key, dateStamp, regionName, serviceName):
	var kDate = signing("AWS4" + key, dateStamp)
	print(kDate)
	assert(kDate == "969fbb94feb542b71ede6f87fe4d5fa29c789342b0f407474670f0c2489e0a0d")
	var kRegion = signing(kDate, regionName)
	assert(kRegion == "69daa0209cd9c5ff5c8ced464a696fd4252e981430b10e3d3fd8e2f197d7a70c")
	var kService = signing(kRegion, serviceName)
	assert(kService == "f72cfd46f26bc4643f06a11eabb6c0ba18780c19a8da0c31ace671265e3c87fa")
	var kSigning = signing(kService, "aws4_request")
	assert(kSigning == "f4780e2d9f65fa895f9c67b32ce1baf0b0d8a43505a000a1a9e090d414db404d")
	return kSigning

func signing(key: String, msg: String):
	var err = ctx.start(HashingContext.HASH_SHA256, key.to_utf8_buffer())
	assert(err == OK)
	err = ctx.update(msg.to_utf8_buffer())
	assert(err == OK)
	var hmac = ctx.finish()
	return hmac


#kDate:  b'\xaao\xe9*\xfd\xf6R\xbe\xac\xee\xbf\x18\xe6\xbd\x15\x11\x1c7WH\x00\x1e\r\xb7\xfc\xe7\xf3\xdb\xf8\x80 \xe4'
#kRegion:  b'\n\xf1*Gm\xaf\x14\xdc\xd7\\YR\x15\xb6l\xdb\x9e\x89\xd3f\xab\xa3b\x80\x0b\xc7\xdd\x183\x89\x8f<'
#kService:  b't;\x97\xde\xb9p\x80T\x92\x85DV+X,\xc68J\xc0:\x86\xa6\xb2<\x82\xa61\xa7\xbcY1\x0f'
#signing_key:  b'\xd5_\xf1?a\x83d\xa7\xed\xeb\x0e\x8f\xc1\xd7\x93\xb4$]z\xf2%4In\x86\xa4\xeeC\x0c3\x14\xb7'
#signature:  b41eba687cb7f0228c3cb38d9d023c82d8c1afd4b35a13580048af1f7bc5cd39
