var _, tableDiv, tableHeader, buildCellText, tbody, longer, hideStyle, percentStyle, drawTable, sortTable, sortByDownload, sortByContent;
_ = require("prelude-ls");
tableDiv = d3.select('#table').append("div");
tableHeader = tableDiv.append("div").attr({
  "class": 'tableHeader'
});
buildCellText = function(tableDiv){
  var build;
  return build = function(cellText, cellStyle, headerText, headerStyle){
    var th, td;
    th = tableHeader.append("div").html(headerText).attr({
      "class": "colName",
      "align": "center"
    }).style({
      "display": "inline-block",
      "width": "80px"
    });
    if (headerStyle !== undefined) {
      th.call(headerStyle);
    }
    td = tableDiv.append("div").html(cellText).attr({
      "class": "cell",
      "align": "right"
    }).style({
      "display": "inline-block",
      "width": "80px"
    });
    if (cellStyle !== undefined) {
      return td.call(cellStyle);
    }
  };
};
tbody = tableDiv.append("div").attr({
  "class": 'tableBody'
});
longer = function(it){
  return it.style({
    "width": "120px"
  });
};
hideStyle = function(it){
  var f;
  f = d3.format("0,000");
  return it.style({
    "opacity": function(){
      if (+d3.select(this).text() === 0) {
        return 0;
      } else {
        return 1;
      }
    }
  }).text(function(){
    return f(
    +d3.select(this).text());
  });
};
percentStyle = function(it){
  return it.style({
    "opacity": function(){
      if (+d3.select(this).text() === 0) {
        return 0;
      } else {
        return 1;
      }
    }
  }).text(function(){
    return (+d3.select(this).text() * 100).toFixed(0) + "%";
  });
};
drawTable = function(data){
  var clickSort, appendCell, rows, positionFunc;
  clickSort = function(it, sortCol){
    var sortTable;
    sortTable = function(data, sortCol){
      if (this.sort === undefined) {
        this.sort = -1;
      } else {
        this.sort = this.sort * (-1);
      }
      return drawTable(
      _.sortBy(function(it){
        return +it[sortCol] * this.sort;
      })(
      data));
    };
    return it.on("mousedown", function(){
      return sortTable(data, sortCol);
    });
  };
  appendCell = function(){
    var cellText;
    d3.selectAll(".colName,.cell").remove();
    cellText = buildCellText(rows);
    cellText(function(it, i){
      return i + 1;
    }, hideStyle, "排名", function(it){
      return clickSort(it, "排名");
    });
    cellText(function(it, i){
      return _.Str.take(4)(
      it.parent);
    }, longer, "機關", longer);
    cellText(function(it, i){
      return _.Str.take(4)(
      it.name);
    }, longer, "名稱", longer);
    cellText(function(it, i){
      return it.total;
    }, hideStyle, "總共", function(it){
      return clickSort(it, "total");
    });
    cellText(function(it, i){
      return it.percOK;
    }, percentStyle, "好資料", function(it){
      return clickSort(it, "percOK");
    });
    cellText(function(it, i){
      return it.percDownload;
    }, percentStyle, "下載問題", function(it){
      return clickSort(it, "percDownload");
    });
    return cellText(function(it, i){
      return it.percContent;
    }, percentStyle, "內容問題", function(it){
      return clickSort(it, "percContent");
    });
  };
  rows = tbody.selectAll(".row").data(data, function(it){
    return it.id;
  });
  rows.exit().remove();
  rows.enter().append("div").attr({
    "class": "row"
  }).style({
    "position": "absolute"
  }).call(appendCell);
  positionFunc = function(i){
    var headerHigh, offset;
    headerHigh = 30;
    offset = function(it){
      return it * headerHigh / 2;
    }(
    Math.floor(
    i / 10));
    return i * 20 + headerHigh + offset + "px";
  };
  return rows.transition().duration(2000).style({
    "top": function(it, i){
      return positionFunc(
      i);
    }
  });
};
sortTable = function(data, sortCol){
  return drawTable(
  _.sortBy(function(it){
    return +it[sortCol] * (-1);
  })(
  data));
};
sortByDownload = null;
sortByContent = null;
d3.csv("./data/stats.csv", function(err, data){
  return d3.csv("./data/relationship.csv", function(err, relaData){
    var relaTbl, nameTbl;
    relaTbl = {};
    nameTbl = {};
    _.map(function(it){
      if (it.children === "" || it.children === undefined) {
        return;
      }
      return _.map(function(child){
        return relaTbl[child] = nameTbl[it["id"]];
      })(
      it.children.split(";"));
    })(
    _.map(function(it){
      nameTbl[it.id] = it.name;
      return it;
    })(
    relaData));
    console.log(
    relaTbl);
    data = _.map(function(it){
      it.percOK = it["OK"] / it.total;
      it.percDownload = it["下載問題"] / it.total;
      it.percContent = it["內容問題"] / it.total;
      it.parent = relaTbl[it.id];
      if (it.parent === undefined) {
        it.parent = "";
      }
      it.name = it.name.replace(it.parent, "");
      return it;
    })(
    data);
    sortByDownload = function(){
      return sortTable(data, "percDownload");
    };
    sortByContent = function(){
      return sortTable(data, "percContent");
    };
    return sortByContent();
  });
});