// Helpers handlebar
Handlebars.registerHelper('colorListItem', function(color) {
  switch (color) {
    case "error":
      return "list-group-item-danger";
    case "ok":
      return "list-group-item-success";
    case "info":
      return "list-group-item-info";
    default:
      return "";
  }
});

Handlebars.registerHelper('selected', function(index, value) {
  if (index === value) {
    return ' selected';
  } else {
    return '';
  }
});

/* ----------------------------------------------------------------------
 * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
 * Digest Algorithm, as defined in RFC 1321.
 * Copyright (C) Paul Johnston 1999 - 2000.
 * Updated by Greg Holt 2000 - 2001.
 * See http://pajhome.org.uk/site/legal.html for details.
----------------------------------------------------------------------- */

var hex_chr = "0123456789abcdef";
function rhex(num)
{
// Convert a 32-bit number to a hex string with ls-byte first
  str = "";
  for(j = 0; j <= 3; j++)
  str += hex_chr.charAt((num >> (j * 8 + 4)) & 0x0F) + hex_chr.charAt((num >> (j * 8)) & 0x0F);
  return str;
}

function str2blks_MD5(str)
{
// Convert a string to a sequence of 16-word blocks, stored as an array.
// Append padding bits and the length, as described in the MD5 standard.
  nblk = ((str.length + 8) >> 6) + 1;
  blks = new Array(nblk * 16);
  for(i = 0; i < nblk * 16; i++) blks[i] = 0;
  for(i = 0; i < str.length; i++)
    blks[i >> 2] |= str.charCodeAt(i) << ((i % 4) * 8);
  blks[i >> 2] |= 0x80 << ((i % 4) * 8);
  blks[nblk * 16 - 2] = str.length * 8;
  return blks;
}

function add(x, y)
{
// Add integers, wrapping at 2^32. This uses 16-bit operations internally to work around bugs in some JS interpreters.
  var lsw = (x & 0xFFFF) + (y & 0xFFFF);
  var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
  return (msw << 16) | (lsw & 0xFFFF);
}

function rol(num, cnt)
{
// Bitwise rotate a 32-bit number to the left
  return (num << cnt) | (num >>> (32 - cnt));
}

// These functions implement the basic operation for each round of the algorithm.
function cmn(q, a, b, x, s, t) { return add(rol(add(add(a, q), add(x, t)), s), b); }
function ff(a, b, c, d, x, s, t) { return cmn((b & c) | ((~b) & d), a, b, x, s, t); }
function gg(a, b, c, d, x, s, t) { return cmn((b & d) | (c & (~d)), a, b, x, s, t); }
function hh(a, b, c, d, x, s, t) { return cmn(b ^ c ^ d, a, b, x, s, t); }
function ii(a, b, c, d, x, s, t) { return cmn(c ^ (b | (~d)), a, b, x, s, t); }

function MD5(str)
{
// Take a string and return the hex representation of its MD5.
  x = str2blks_MD5(str);
  var a =  1732584193;
  var b = -271733879;
  var c = -1732584194;
  var d =  271733878;

  for(i = 0; i < x.length; i += 16) {
    var olda = a;
    var oldb = b;
    var oldc = c;
    var oldd = d;

    a = ff(a, b, c, d, x[i+ 0], 7 , -680876936);
    d = ff(d, a, b, c, x[i+ 1], 12, -389564586);
    c = ff(c, d, a, b, x[i+ 2], 17,  606105819);
    b = ff(b, c, d, a, x[i+ 3], 22, -1044525330);
    a = ff(a, b, c, d, x[i+ 4], 7 , -176418897);
    d = ff(d, a, b, c, x[i+ 5], 12,  1200080426);
    c = ff(c, d, a, b, x[i+ 6], 17, -1473231341);
    b = ff(b, c, d, a, x[i+ 7], 22, -45705983);
    a = ff(a, b, c, d, x[i+ 8], 7 ,  1770035416);
    d = ff(d, a, b, c, x[i+ 9], 12, -1958414417);
    c = ff(c, d, a, b, x[i+10], 17, -42063);
    b = ff(b, c, d, a, x[i+11], 22, -1990404162);
    a = ff(a, b, c, d, x[i+12], 7 ,  1804603682);
    d = ff(d, a, b, c, x[i+13], 12, -40341101);
    c = ff(c, d, a, b, x[i+14], 17, -1502002290);
    b = ff(b, c, d, a, x[i+15], 22,  1236535329);

    a = gg(a, b, c, d, x[i+ 1], 5 , -165796510);
    d = gg(d, a, b, c, x[i+ 6], 9 , -1069501632);
    c = gg(c, d, a, b, x[i+11], 14,  643717713);
    b = gg(b, c, d, a, x[i+ 0], 20, -373897302);
    a = gg(a, b, c, d, x[i+ 5], 5 , -701558691);
    d = gg(d, a, b, c, x[i+10], 9 ,  38016083);
    c = gg(c, d, a, b, x[i+15], 14, -660478335);
    b = gg(b, c, d, a, x[i+ 4], 20, -405537848);
    a = gg(a, b, c, d, x[i+ 9], 5 ,  568446438);
    d = gg(d, a, b, c, x[i+14], 9 , -1019803690);
    c = gg(c, d, a, b, x[i+ 3], 14, -187363961);
    b = gg(b, c, d, a, x[i+ 8], 20,  1163531501);
    a = gg(a, b, c, d, x[i+13], 5 , -1444681467);
    d = gg(d, a, b, c, x[i+ 2], 9 , -51403784);
    c = gg(c, d, a, b, x[i+ 7], 14,  1735328473);
    b = gg(b, c, d, a, x[i+12], 20, -1926607734);

    a = hh(a, b, c, d, x[i+ 5], 4 , -378558);
    d = hh(d, a, b, c, x[i+ 8], 11, -2022574463);
    c = hh(c, d, a, b, x[i+11], 16,  1839030562);
    b = hh(b, c, d, a, x[i+14], 23, -35309556);
    a = hh(a, b, c, d, x[i+ 1], 4 , -1530992060);
    d = hh(d, a, b, c, x[i+ 4], 11,  1272893353);
    c = hh(c, d, a, b, x[i+ 7], 16, -155497632);
    b = hh(b, c, d, a, x[i+10], 23, -1094730640);
    a = hh(a, b, c, d, x[i+13], 4 ,  681279174);
    d = hh(d, a, b, c, x[i+ 0], 11, -358537222);
    c = hh(c, d, a, b, x[i+ 3], 16, -722521979);
    b = hh(b, c, d, a, x[i+ 6], 23,  76029189);
    a = hh(a, b, c, d, x[i+ 9], 4 , -640364487);
    d = hh(d, a, b, c, x[i+12], 11, -421815835);
    c = hh(c, d, a, b, x[i+15], 16,  530742520);
    b = hh(b, c, d, a, x[i+ 2], 23, -995338651);

    a = ii(a, b, c, d, x[i+ 0], 6 , -198630844);
    d = ii(d, a, b, c, x[i+ 7], 10,  1126891415);
    c = ii(c, d, a, b, x[i+14], 15, -1416354905);
    b = ii(b, c, d, a, x[i+ 5], 21, -57434055);
    a = ii(a, b, c, d, x[i+12], 6 ,  1700485571);
    d = ii(d, a, b, c, x[i+ 3], 10, -1894986606);
    c = ii(c, d, a, b, x[i+10], 15, -1051523);
    b = ii(b, c, d, a, x[i+ 1], 21, -2054922799);
    a = ii(a, b, c, d, x[i+ 8], 6 ,  1873313359);
    d = ii(d, a, b, c, x[i+15], 10, -30611744);
    c = ii(c, d, a, b, x[i+ 6], 15, -1560198380);
    b = ii(b, c, d, a, x[i+13], 21,  1309151649);
    a = ii(a, b, c, d, x[i+ 4], 6 , -145523070);
    d = ii(d, a, b, c, x[i+11], 10, -1120210379);
    c = ii(c, d, a, b, x[i+ 2], 15,  718787259);
    b = ii(b, c, d, a, x[i+ 9], 21, -343485551);

    a = add(a, olda);
    b = add(b, oldb);
    c = add(c, oldc);
    d = add(d, oldd);
  }
  return rhex(a) + rhex(b) + rhex(c) + rhex(d);
}


/**
 * Cursor Functions
 *
 * Used for setting and getting text cursor position within an input
 * and textarea field. Also used to get and set selection range.
 *
 * @author Branden Cash
 * @email brandencash@crutzdesigns.com
 */

(function( $ ){

  jQuery.fn.exists = function(){return this.length>0;}

  jQuery.fn.serializeObject = function(){
    // Résultat d'un formulaire sous forme d'un objet
    var j,theArray,len,out,it
    theArray = $(this).serializeArray()
    out = {}
    for (j = 0, len = theArray.length; j < len; j++) {
        it = theArray[j];
        out[it.name] = it.value;
      }
      return out;
  }

  jQuery.fn.adjustSize = function(){
    // ajout perso pour rendre la hauteur égale à la largeur
    var w = $(this).width();
    $(this).height(w);
    //$(this).width(w);
  }

  jQuery.fn.getCursorPosition = function(){
    if(this.length == 0) return -1;
    return $(this).getSelectionStart();
  }

  jQuery.fn.setCursorPosition = function(position){
    if(this.length == 0) return this;
    return $(this).setSelection(position, position);
  }

  jQuery.fn.getSelection = function(){
    if(this.length == 0) return -1;
    var s = $(this).getSelectionStart();
    var e = $(this).getSelectionEnd();
    return this[0].value.substring(s,e);
  }

  jQuery.fn.getSelectionStart = function(){
    if(this.length == 0) return -1;
    input = this[0];

    var pos = input.value.length;

    if (input.createTextRange) {
      var r = document.selection.createRange().duplicate();
      r.moveEnd('character', input.value.length);
      if (r.text == '')
        pos = input.value.length;
      pos = input.value.lastIndexOf(r.text);
    } else if(typeof(input.selectionStart)!="undefined")
      pos = input.selectionStart;

    return pos;
  }

  jQuery.fn.getSelectionEnd = function(){
    if(this.length == 0) return -1;
    input = this[0];

    var pos = input.value.length;

    if (input.createTextRange) {
      var r = document.selection.createRange().duplicate();
      r.moveStart('character', -input.value.length);
      if (r.text == '')
        pos = input.value.length;
      pos = input.value.lastIndexOf(r.text);
    } else if(typeof(input.selectionEnd)!="undefined")
      pos = input.selectionEnd;

    return pos;
  }

  jQuery.fn.setSelection = function(selectionStart, selectionEnd) {
    if(this.length == 0) return this;
    input = this[0];

    if (input.createTextRange) {
      var range = input.createTextRange();
      range.collapse(true);
      range.moveEnd('character', selectionEnd);
      range.moveStart('character', selectionStart);
      range.select();
    } else if (input.setSelectionRange) {
      input.focus();
      input.setSelectionRange(selectionStart, selectionEnd);
    }

    return this;
  }
})( jQuery );
