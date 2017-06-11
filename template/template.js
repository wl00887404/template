$('document').ready(function() {
    $.getScript('assets/jquery.multiple.select.js');
    var css = $.parseHTML('<link href="assets/multiple-select.css" rel="stylesheet" /><link href="assets/templateManage.css" rel="stylesheet" /><link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" />');
    $('head').prepend(css);
});
$.prototype.template = function(option) {

    if (!option) {
        option = {};
    }
    var height = option.height != undefined ? option.height : 500;
    var width = option.width != undefined ? option.width : 608.95;
    var atTop = option.atTop != undefined ? option.atTop : undefined;
    var atRight = option.atRight != undefined ? option.atRight : undefined;
    var intoWhere = option.intoWhere != undefined ? option.intoWhere : undefined;
    var callback = option.callback != undefined ? option.callback : undefined;
    var outputType = option.outputType != undefined ? option.outputType : undefined;
    this.css({ cursor: 'pointer' });
    this.click(function() {
        var data;
        if (document.getElementById('templateMainBubble') != null) {
            return false;
        }
        $.ajax({
            url: "templateManage.asmx/getTemplateXml",
            async: false,
            type: 'POST',
            data: '',
            datatype: 'xml',
            success: function(xml) {
                data = xml;

            },
            error: function(xhr, status, err) {
                console.error("templateManage.asmx/getTemplateXml", status, err.toString());
            }
        });
        if (data == undefined) {
            return false;
        }
        if (option.focus != undefined) {
            var str = option.focus.split('>');
            str = str.map(function(item, i) {
                if (i == 0) {
                    return "/root[@name='目錄']"
                } else {
                    if (item == '') {
                        return "/directory";
                    } else {
                        return "/directory[@name='" + item + "']";
                    }
                }
            }).reduce(function(a, b) {
                return a + b;
            });
            var node = document.evaluate(str, data, null, XPathResult.ANY_TYPE, null).iterateNext();
            if (node != null) {
                root = $.parseXML("<root name='" + node.getAttribute('name') + "'></root>");
                rootElement = root.getElementsByTagName('root')[0];
                for (var i = 0; i < node.children.length; i++) {
                    rootElement.appendChild(node.children[i]);
                }
                data = root;
            }
        }

        var main = Main(data, $(this).offset().left, $(this).offset().top, $(this).outerWidth(), $(this).outerHeight());
        $('body').prepend(main);
        $('.DirListItemChildrenNodesDiv:first').children('.verticalLine').outerHeight($('.DirListItemChildrenNodesDiv:first').outerHeight() - $('.DirListItemChildrenNodesDiv:first').children('.DirListItem:last').outerHeight() + 22.5);
    });

    function Main(data, x, y, w, h) {
        var self = $.parseHTML('<div id="templateMainBubble" class="boundBlock"></div>');
        var dirList = $.parseHTML('<div id="directoryMenu" style="height:100%;">' + '</div>')[0];
        var root = DirListItem(data.getElementsByTagName('root')[0]);
        $(dirList).append(root);
        var cancel = $.parseHTML('<button type="button" class="btn btn-primary">取消</button>')[0];
        $(cancel).click(function() {
            $(self).remove();
        });

        var buttonPanel = $.parseHTML('<div id="saveButtons"></div>')[0];
        $(buttonPanel).append(cancel);
        $(dirList).append(buttonPanel);
        $(self).append(dirList);
        $(self).css({ width: width + 'px', height: height + 'px', position: 'absolute', backgroundColor: 'white', zIndex: '3', textAlign: 'left', marginTop: '0px', padding: '20px', color: 'black' });
        if (atTop == undefined) {
            if ((y - height - 10) > 0) {
                atTop = true;
            } else {
                atTop = false;
            }
        }
        if (atRight == undefined) {
            if ((x - width) > 0) {
                atRight = false;
            } else {
                atRight = true;
            }
        }

        if (atTop && atRight) {
            //右上
            var arrowStyle = { position: 'absolute', bottom: '-18.2px', left: '6px', width: '0px', height: '0px', border: '10px solid transparent', borderTopColor: 'white', zIndex: "6" };
            var bArrowStyle = { position: 'absolute', bottom: '-20.2px', left: '6px', width: '0px', height: '0px', border: '10px solid transparent', borderTopColor: '#e3e3e3', zIndex: "4" };
            var css = { top: y - height - 10, left: x }
        } else if (atTop == true && atRight != true) {
            //左上
            var arrowStyle = { position: 'absolute', bottom: '-18.2px', right: '6px', width: '0px', height: '0px', border: '10px solid transparent', borderTopColor: 'white', zIndex: "6" };
            var bArrowStyle = { position: 'absolute', bottom: '-20.2px', right: '6px', width: '0px', height: '0px', border: '10px solid transparent', borderTopColor: '#e3e3e3', zIndex: "4" };
            var css = { top: y - height - 10, left: x - width + w }

        } else if (atTop != true && atRight == true) {
            //右下
            var arrowStyle = { position: 'absolute', top: '-18.2px', left: '6px', width: '0px', height: '0px', border: '10px solid transparent', borderBottomColor: 'white', zIndex: "6" };
            var bArrowStyle = { position: 'absolute', top: '-20.2px', left: '6px', width: '0px', height: '0px', border: '10px solid transparent', borderBottomColor: '#e3e3e3', zIndex: "4" };
            var css = { top: y + h + 10, left: x }

        } else {
            //左下
            var arrowStyle = { position: 'absolute', top: '-18.2px', right: '6px', width: '0px', height: '0px', border: '10px solid transparent', borderBottomColor: 'white', zIndex: "6" };
            var bArrowStyle = { position: 'absolute', top: '-20.2px', right: '6px', width: '0px', height: '0px', border: '10px solid transparent', borderBottomColor: '#e3e3e3', zIndex: "4" };
            var css = { top: y + h + 10, left: x - width + w }
        }

        $(self).append($('<div/>').css(arrowStyle), $('<div/>').css(bArrowStyle));
        $(self).css(css);
        return self
    }

    function DirListItem(data) {
        var self = $.parseHTML('<div class="DirListItem"></div>')[0];
        if (data.tagName == 'root' || data.tagName == 'directory') {
            var profiles = data.childNodes;
            var arr = [];
            for (var key in profiles) {
                arr.push(profiles[key]);
            }
            var children = arr.filter(function(children) {
                if ((children.tagName == 'directory') || (children.tagName == 'template')) {
                    return true;
                } else {
                    return false;
                }
            }).sort(function(a, b) {
                return a.tagName.charCodeAt(0) - b.tagName.charCodeAt(0);
            }).map(function(children, i) {
                return DirListItem(children);
            });

            if (children.length != 0) {
                if (data.tagName == 'root') {
                    var dirListItemChildrenNodesDiv = DirListItemChildrenNodesDiv(children, true);
                } else {
                    var dirListItemChildrenNodesDiv = DirListItemChildrenNodesDiv(children);
                }
            }
        } else {
            var children = { length: 0 };
        }
        var name = DirListItemName(data, dirListItemChildrenNodesDiv);
        $(self).append(name);
        if (dirListItemChildrenNodesDiv != undefined) {
            $(self).append(dirListItemChildrenNodesDiv);
        }
        return self;
    }

    function DirListItemChildrenNodesDiv(children, open) {
        var self = $.parseHTML('<div class="DirListItemChildrenNodesDiv"></div>')[0];
        var line = '<div class="verticalLine" style="width:0px; float:left;border-left:1px solid black"></div>';
        if (open == true) { $(self).css({ display: 'block' }) } else { $(self).css({ display: 'none' }); }
        $(self).append(line);
        for (var i = 0; i < children.length; i++) {
            $(self).append(children[i]);
        }
        return self;
    }

    function DirListItemName(data, childDiv) {
        var self = $.parseHTML('<div class="DirListItemName"></div>')[0];
        switch (data.tagName) {
            case 'root':
                var style = { position: 'relative', left: '15px' };
                var icon = '<span class="glyphicon glyphicon-folder-open" style="color:rgb(255, 204, 0);font-size:20px;margin:0px 5px;"></span>';
                break;
            case 'template':
                var dash = '<span class="dash" style="padding:0px;margin:0px;width:20px;border-bottom:black 1px solid;"}>　</span>';
                var icon = '<span class="glyphicon glyphicon glyphicon-list-alt" style="color:#1a1a1a;font-size:20px;margin:0px 5px;"></span>';
                break;
            case 'directory':
                var dash = '<span class="dash" style="padding:0px;margin:0px;width:20px;border-bottom:black 1px solid;"}>　</span>';
                var icon = '<span class="glyphicon glyphicon-folder-open" style="color:rgb(255, 204, 0);font-size:20px;margin:0px 5px;"></span>';
                if (childDiv != undefined) {
                    var switchButton = $.parseHTML('<button class="directoryMenuSwitch">+</button>')[0];
                    $(switchButton).click(function() {
                        if ($(childDiv).css('display') == 'block') {
                            $(childDiv).css({ 'display': 'none' });
                            this.innerHTML = '+';
                        } else {
                            $(childDiv).css({ 'display': 'block' });
                            this.innerHTML = '-';
                        }

                        $(childDiv).children('.verticalLine').outerHeight($(childDiv).outerHeight() - $(childDiv).children('.DirListItem:last').outerHeight() + 22.5);
                        $(this).parents('.DirListItemChildrenNodesDiv').each(function() {
                            var subheight = $(this).outerHeight() - $(this).children('.DirListItem:last').outerHeight();
                            $(this).children('.verticalLine').outerHeight(subheight + 22.5);
                        });

                    })
                }
                break;
            default:
                break;
        }
        var name = $.parseHTML('<span>' + icon + '<span>' + data.getAttribute('name') + '</span>' + '</span>')[0];
        if (data.tagName == 'template') {
            $(name).css({ cursor: 'pointer' });
            $(name).click(function() {
                loadTemp(data);
            });
        }

        if (style != undefined) $(self).css(style);
        if (dash != undefined) $(self).append(dash);
        if (switchButton != undefined) $(self).append(switchButton);
        $(self).append(name); /*<span onClick={click}> to load temp*/ /*var spanStyle={cursor:'pointer'};*/
        return self;

    }

    function loadTemp(data) {
        var self = $.parseHTML('<div id="templatePanel"style="height:100%;"></div>');
        $('#directoryMenu').hide();
        var profiles = data.childNodes;
        var arr = [];
        for (var key in profiles) {
            if (profiles[key].nodeType == 1) {
                arr.push(profiles[key]);
            }
        }
        var templateName = '<div id="templateName" >' + data.getAttribute('name') + '</div>';
        var templateContentItem = arr.map(function(data, i) {
            return TemplateContentItem(data, i);
        });
        var templateContent = $.parseHTML('<div id="templateContent" style="height:80%"></div>')[0];
        $(templateContent).append(templateContentItem);
        var submit = $.parseHTML('<button type="button" class="btn btn-primary">確定</button>')[0];
        $(submit).click(function() {
            getTempHtml(arr);
        })
        var cancel = $.parseHTML('<button type="button" class="btn btn-primary">取消</button>')[0];
        $(cancel).click(function() {
            $('#directoryMenu').show();
            $(self).remove();
        });
        var buttonPanel = $.parseHTML('<div id="saveButtons"></div>')[0];
        $(buttonPanel).append(submit, cancel);

        $(self).append(templateName, templateContent, buttonPanel);
        $('#templateMainBubble:last').append(self);
        $('#templatePanel select:not([multiple])').multipleSelect({ width: 100, single: true, placeholder: "單選" }).parent().removeAttr('style');
        $('#templatePanel select[multiple]').multipleSelect({ width: 150, placeholder: "多選", selectAll: false, ellipsis: true, countSelected: false }).parent().removeAttr('style');
    }

    function TemplateContentItem(data, i) {
        var className = 'inputDiv';
        switch (data.tagName) {
            case "text":
                var inputArea = '<span>' + data.innerHTML + '</span>';
                break;

            case "inputTextBox":
                var inputArea = "<input type='text' className='inputTextBox' placeholder='" + data.innerHTML + "'/>";
                break;

            case "dropdown":
                var items = data.innerHTML.split(',');
                items.unshift("");
                items = items.filter(function(item, i) {
                    if (item == '' && i != 0) {
                        return false;
                    } else {
                        return true
                    }
                }).map(function(item) {
                    if (item == '') {
                        return "<option value='" + item + "'>不選取</option>";
                    } else {
                        return "<option value='" + item + "'>" + item + "</option>";
                    }
                }).reduce(function(a, b) {
                    return a + b });
                var inputArea = "<select name='" + i + "''>" + items + "</select>";
                break;

            case "dropdown_checkbox":
                var items = data.innerHTML.split(',');
                var items = items.filter(function(item, i) {
                    if (item == '') {
                        return false;
                    } else {
                        return true;
                    }
                }).map(function(item) {
                    return "<option value='" + item + "'>" + item + "</option>";
                }).reduce(function(a, b) {
                    return a + b });
                var inputArea = "<select multiple name='" + i + "''>" + items + "</select>";
                break;

            case "lineFeed":
                className += ' lineFeed';
                var inputArea = '<div class="dotDash"></div>';
                break;

            case "image":
                var inputArea = "<img src='" + data.innerHTML + "' width='100%' alt='無法連接圖片' />";
                break;

            default:
                break;
        }
        return $.parseHTML("<div class='" + className + "'>" + inputArea + "</div>")[0];
    }

    function getTempHtml(dataArr) {
        if (outputType == 'text') {
            var returnObj = dataArr.map(function(data, i) {

                switch (data.tagName) {
                    case "text":
                        return data.innerHTML;
                        break;

                    case "inputTextBox":
                        return $('.inputDiv:eq(' + i + ')').val();
                        break;

                    case "dropdown":
                        return $('.inputDiv:eq(' + i + ') select').multipleSelect("getSelects");
                        break;

                    case "dropdown_checkbox":
                        return $('.inputDiv:eq(' + i + ') select').multipleSelect("getSelects");
                        break;

                    case "lineFeed":
                        return '\n'
                        break;

                    case "image":
                        break;

                    default:
                        break;
                }
            }).reduce(function(a, b) {
                return a + b;
            });
        } else {
            var returnObj = dataArr.map(function(data, i) {

                switch (data.tagName) {
                    case "text":
                        return '<span>' + data.innerHTML + '</span>';
                        break;

                    case "inputTextBox":
                        return '<span>' + $('.inputDiv:eq(' + i + ')').val() + '</span>';
                        break;

                    case "dropdown":
                        return '<span>' + $('.inputDiv:eq(' + i + ') select').multipleSelect("getSelects") + '</span>';
                        break;

                    case "dropdown_checkbox":
                        return '<span>' + $('.inputDiv:eq(' + i + ') select').multipleSelect("getSelects") + '</span>';
                        break;

                    case "lineFeed":
                        return '<br />'
                        break;

                    case "image":
                        return "<img src='" + data.innerHTML + "' width='100%' alt='無法連接圖片' />";
                        break;

                    default:
                        break;
                }
            }).reduce(function(a, b) {
                return a + b;
            });

        };
        $('#templateMainBubble').remove();
        if (intoWhere != undefined) {
            $(intoWhere).append(returnObj);
        }
        if (callback != undefined) {
            callback(returnObj);
        }
    }
}
