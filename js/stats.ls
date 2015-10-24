_ = require "prelude-ls"



tableDiv = d3.select '#table' .append "div"

### maybe this is not a good idea, might added by columns
tableHeader =  tableDiv
	.append "div"
	.attr {
		"class": 'tableHeader'
	}

buildCellText = (tableDiv)->
	build = (cellText, cellStyle, headerText, headerStyle)->
		th = tableHeader
			.append "div"
			.html headerText
			.attr {
				"class": "colName"
				"align": "center"
			}
			.style {
				"display": "inline-block"
				"width": "80px"
			}

		if headerStyle is not undefined then th.call headerStyle

		td = tableDiv
			.append "div"
			.html cellText
			.attr {
				"class": "cell"
				"align": "right"
			}
			.style {
				"display": "inline-block"
				"width": "80px"
			}

		if cellStyle is not undefined then td.call cellStyle


tbody = tableDiv
	.append "div"
	.attr {
		"class": 'tableBody'
	}


longer = ->
	it
		.style {
			"width": "120px"
		}

hideStyle = ->
	f = d3.format "0,000"
	it
		.style {
			"opacity": -> if +(d3.select @ .text!) is 0 then 0 else 1
		}
		.text -> +(d3.select @ .text!) |> f

percentStyle = ->
	it
		.style {
			"opacity": -> if +(d3.select @ .text!) is 0 then 0 else 1
		}
		.text -> ((+(d3.select @ .text!) * 100).toFixed 0) + "%"




# sortByDownload = null
# sortByContent = null

# err, data <- d3.csv "./data/stats.csv"

# data = data |> _.map (->
# 	it.percDownload = it["下載問題"] / it.total
# 	it.percContent = it["內容問題"] / it.total
# 	it
# 	)
# 	### if @sortCol is undefined then @sortCol := sortCol

# sortByDownload := (-> sortTable data, "percDownload" )
# sortByContent := (-> sortTable data, "percContent" )

drawTable = (data)->

	clickSort = (it, sortCol)->
		sortTable = (data, sortCol)->
			if @sort is undefined then @sort := -1 else @sort := @sort * (-1)
			data
			|> _.sort-by(-> +it[sortCol] * @sort )
			|> drawTable

		it
			.on "mousedown", -> sortTable data, sortCol

	appendCell = ->
		d3.selectAll ".colName,.cell" .remove!
		
		cellText = buildCellText rows
		cellText (it, i)-> (i + 1), hideStyle, "排名", (-> clickSort it, "排名")
		cellText ((it, i)-> it.parent |> (_.Str.take 4) ), longer, "機關", longer
		cellText ((it, i)-> it.name |> (_.Str.take 4) ), longer, "名稱", longer ### (-> clickSort it, "name")
		cellText ((it, i)-> it.total), hideStyle, "總共", (-> clickSort it, "total")
		cellText ((it, i)-> it.percOK), percentStyle, "好資料", (-> clickSort it, "percOK")
		cellText ((it, i)-> it.percDownload), percentStyle, "下載問題", (-> clickSort it, "percDownload")
		cellText ((it, i)-> it.percContent), percentStyle, "內容問題", (-> clickSort it, "percContent")
		# cellText ((it, i)-> it["內容問題/亂碼"]), hideStyle, "亂碼", (-> )
		# cellText ((it, i)-> it["內容問題/欄位過長"]), hideStyle, "欄位過長", (-> )
		# cellText ((it, i)-> it["內容問題/空白欄位"]), hideStyle, "空白欄位", (-> )
		# cellText ((it, i)-> it["內容問題/純數字欄位"]), hideStyle, "純數字欄位", (-> )
		# cellText ((it, i)-> it["內容問題/重覆欄位"]), hideStyle, "重覆欄位", (-> )


	rows = tbody
		.selectAll ".row"
		.data data, -> it.id
		

	rows
		.exit!
		.remove!

	rows
		.enter!
		.append "div"
		.attr {
			"class": "row"
		}
		.style {
			"position": "absolute"
		}
		.call appendCell

	# (i / 10) |> Math.floor

	positionFunc = (i)->
		headerHigh = 30
		offset = (i / 10) |> Math.floor |> (-> it * headerHigh / 2)
		i * 20 + headerHigh + offset + "px"

	rows
		.transition!
		.duration 2000
		.style {
			"top": (it, i)-> i |> positionFunc
		}



sortTable = (data, sortCol)->
	data
	|> _.sort-by(-> +it[sortCol] * (-1) )
	|> drawTable


sortByDownload = null
sortByContent = null




err, data <- d3.csv "./data/stats.csv"
err, relaData <- d3.csv "./data/relationship.csv"

relaTbl = {}
nameTbl = {}
relaData
|> _.map (->
	nameTbl[it.id] := it.name
	it
	)
|> _.map (->
	if (it.children is "") or (it.children is undefined) then return
	it.children.split ";" |> _.map ((child)-> relaTbl[child] := nameTbl[it["id"]])
	)

# nameTbl |> console.log 
relaTbl |> console.log 

data := data |> _.map (->

	it.percOK = it["OK"] / it.total
	it.percDownload = it["下載問題"] / it.total
	it.percContent = it["內容問題"] / it.total
	it.parent = relaTbl[it.id]
	if it.parent is undefined then it.parent = ""
	it.name = (it.name.replace it.parent, "")
	it
	)
	### if @sortCol is undefined then @sortCol := sortCol

sortByDownload := (-> sortTable data, "percDownload" )
sortByContent := (-> sortTable data, "percContent" )

sortByContent!

