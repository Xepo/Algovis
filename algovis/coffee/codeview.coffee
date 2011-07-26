#Taken from http://stackoverflow.com/questions/499126/jquery-set-cursor-position-in-text-area
`new function($) {
  $.fn.setCursorPosition = function(pos) {
    if ($(this).get(0).setSelectionRange) {
      $(this).get(0).setSelectionRange(pos, pos);
    } else if ($(this).get(0).createTextRange) {
      var range = $(this).get(0).createTextRange();
      range.collapse(true);
      range.moveEnd('character', pos);
      range.moveStart('character', pos);
      range.select();
    }
  }
}(jQuery);`


@jQuery.fn.insertAtCursor = (str) ->
	pos = $(this).caret().start
	text = $(this).val()
	
	$(this).val text.substr(0, pos) + str + text.substr(pos)
	$(this).setCursorPosition pos + str.length

@jQuery.fn.makeCodeView = ->
		$(this).linedtextarea()

		$(this).keydown (event) ->
			if event.keyCode == 9
				$(this).insertAtCursor '\t'
				event.preventDefault()

		$(this).keyup (event) ->
			if event.keyCode == 13
				pos = $(this).caret().start
				text = $(this).val()
				lastnewline = text.lastIndexOf "\n", pos-2
				return if lastnewline == -1

				lastline = text.substr lastnewline+1, pos-lastnewline
				indent = lastline.match /^[ \t]*/
				if indent?.length > 0
					$(this).insertAtCursor indent[0]
