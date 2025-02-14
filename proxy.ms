rollout ProxyTools "Proxy Tools" width:206 height:187
(
	-- UI
	button 'btnCount' "Total Proxy Count" pos:[5,8] width:103 height:21 align:#left
	button 'btnIndividualSize' "Individual Proxy Sizes" pos:[5,32] width:120 height:21 align:#left
	button 'btnTotalSize' "Total Proxy Size" pos:[5,56] width:93 height:21 align:#left
	button 'btnbtmpres' "BitMap Res 2K to 4K" pos:[4,80] width:187 height:18 align:#left
	edittext 'edtOutput' "Output" pos:[8,106] width:185 height:60 readOnly:true align:#left
	
	--gating proxy form the scene
	function getProxyObjects =
	(
		local proxies = for obj in geometry where (classof obj == CProxy) collect obj
		return proxies
	)
	
	--counting all unique proxy objects 
	on btnCount pressed do
	(
		local proxies = getProxyObjects()
		local uniqueProxies = #()
		for proxy in proxies do
		(
			if findItem uniqueProxies proxy.fileName == 0 do
				append uniqueProxies proxy.fileName
		)
		
		edtOutput.text = "Total Proxies: " + uniqueProxies.count as string
		if uniqueProxies.count == 0 then edtOutput.text = "No Proxies Found"
	)

	--getting the size of each unique proxy object
	on btnIndividualSize pressed do
	(
		local proxies = getProxyObjects()
		local uniqueProxies = #()
		local output = ""
		for proxy in proxies do
		(
			if findItem uniqueProxies proxy.fileName == 0 do
			(
				append uniqueProxies proxy.fileName
				output += proxy.name + ": " + (getFileSize proxy.fileName/1024.00/1024.00) as string + " MB\n"
			)
		)
		edtOutput.text = output
	)

	-- getting total size of proxy
	on btnTotalsize pressed do
	(
		local proxies = getProxyObjects()
		local uniqueProxies = #()
		local totalSize = 0
		for proxy in proxies do
		(
			if findItem uniqueProxies proxy.fileName == 0 do
			(
				append uniqueProxies proxy.fileName
				totalSize += getFileSize proxy.fileName
			)	
		)

		
	)
	--getting the total size of all unique proxy objects
	on btnTotalSize pressed do
	(
		local proxies = getProxyObjects()
		local uniqueProxies = #()
		local totalSize = 0
		for proxy in proxies do
		(
			if findItem uniqueProxies proxy.fileName == 0 do
			(
				append uniqueProxies proxy.fileName
				totalSize += (getFileSize proxy.fileName)
			)
		)
		edtOutput.text = "Total Proxy Size: " + (totalSize/1024.00/1024.00) as string + " MB\n"
	)
	function isHighRes bitmapTex = (
		if (isKindOf bitmapTex Bitmaptexture) then (
			local bmp = bitmapTex.bitmap
			if (bmp.width >= 2048 and bmp.width < 3840) or (bmp.height >= 2048 and bmp.height < 2160) then (
				local bname = getFilenameFile bitmapTex.filename
				local parentMat = refs.dependentNodes bitmapTex
				local matName = if parentMat.count > 0 then parentMat[1].name else "None"
				format "Bitmap: %\nResolution: % x %\nUsed in Material: %\n" bname bmp.width bmp.height matName
			)
		)
	)

	function processAllBitmaps = (
		local allBitmaps = getClassInstances Bitmaptexture
		for tex in allBitmaps do (
			isHighRes tex
		)
	)

	on btnbtmpres pressed do
	(
		 processAllBitmaps()
	)
)

createDialog ProxyTools 300 200
