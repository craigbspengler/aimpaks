/*
* This does things we need for aim offerings -- it is consolidated with stuff from
* lots of different places, sections are documented inline, below.
*/
function aim_font_bold(targetId)
{
  var it = $(targetId);
  it.style.fontWeight = 'bold'; 
}

function aim_font_normal(targetId)
{
  var it = $(targetId);
  it.style.fontWeight = 'normal'; 
}

/* This is to help switch block display on and off. */

function aim_toggle(targetSelectors)
{
  var ts = $A(targetSelectors);
  
  for(var i=0; i<ts.length; i++) 
  {
		var it = ts[i];
    alert(it);
    if (it.style.display == 'none' || it.style.display == '')
      it.style.display = 'block';
    else
      it.style.display = 'none'; 
  };
}
/** *******************************************************************************
    * http://www.javadonkey.com/blog/javascript-set-focus-to-first-form-field/
    *
    * Sets focus to first field on page
    *
    *  If you are building web applications, chances are you might need to set
    *   focus to the first field  on the HTML form when the web page loads.   
    *   This is a fairly common business requirement so that users can just start
    *    filling out the application instead of having to click or tab to that
    *     first field.  Here is a very simple JavaScript that will automatically 
    *     find the first field on the first form and set focus to it.  
    *     (Sorry I couldn&#8217;t get the code to format correctly&#8230;)
    *
    *  also...
    *
    *     I made a similar function to do this.. so I thought I’d add some of
    *     my additions.
    * 
    *  1.) exclude readonly fields too
    *  2.) you may want to exclude radio/checkboxes… as the focus on them can be
    *      awkward.
    *  3.) for text & password fields, you may prefer to call .select() instead.
    *      this will highlight the text content as well, which makes a re-type
    *       much easier.
    *
    */
    function setFocusFirstField()
    {
    try
    {
    var bFound = false;
    for (f=0; f < document.forms.length; f++)
    {
    for(i=0; i < document.forms[f].length; i++)
    {
    if (document.forms[f][i].type != "hidden")
    {
    if (document.forms[f][i].disabled != true)
    {
    document.forms[f][i].select();
    var bFound = true;
    }
    }
    if (bFound == true)
    {
    break;
    }
    }
    if (bFound == true)
    {
    break;
    }
    }
    }
    catch(e)
    {
    // do nothing
    }

    }
/* *******************************************************************************
* This is built up from:
*
* http://www.texsoft.it/index.php?c=software&m=sw.js.htmltooltip&l=it
*
*/
function xstooltip_findPosX(obj) 
{
  var curleft = 0;
  if (obj.offsetParent) 
  {
    while (obj.offsetParent) 
        {
            curleft += obj.offsetLeft
            obj = obj.offsetParent;
        }
    }
    else if (obj.x)
        curleft += obj.x;
    return curleft;
}

function xstooltip_findPosY(obj) 
{
    var curtop = 0;
    if (obj.offsetParent) 
    {
        while (obj.offsetParent) 
        {
            curtop += obj.offsetTop
            obj = obj.offsetParent;
        }
    }
    else if (obj.y)
        curtop += obj.y;
    return curtop;
}

function xstooltip_show(tooltipId, parentId, posX, posY)
{
    it = document.getElementById(tooltipId);
    
    if ((it.style.top == '' || it.style.top == 0) 
        && (it.style.left == '' || it.style.left == 0))
    {
        // need to fixate default size (MSIE problem)
        it.style.width = it.offsetWidth + 'px';
        it.style.height = it.offsetHeight + 'px';
        
        img = document.getElementById(parentId); 
    
        // if tooltip is too wide, shift left to be within parent 
        if (posX + it.offsetWidth > img.offsetWidth) posX = img.offsetWidth - it.offsetWidth;
        if (posX < 0 ) posX = 0; 
        
        x = xstooltip_findPosX(img) + posX;
        y = xstooltip_findPosY(img) + posY;
        
        it.style.top = y + 'px';
        it.style.left = x + 'px';
    }
    
    it.style.visibility = 'visible'; 
}

function xstooltip_hide(id)
{
    it = document.getElementById(id); 
    it.style.visibility = 'hidden'; 
}

