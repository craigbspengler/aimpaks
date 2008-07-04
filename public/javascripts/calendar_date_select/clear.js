// Cancel button
_translations["Clear"] = "Clear";
_translations["Cancel"] = "Cancel";

function alias_method_chain(parent, method_name, suffix) {
  if (typeof(parent[method_name + "Without" + suffix]) == "undefined") {
    parent[method_name + "Without" + suffix] = parent[method_name]
    parent[method_name] = parent[method_name + "With" + suffix]
  }
}
CalendarDateSelect.prototype.aux_buttons_div = function() { return this._aux_buttons_div ? this._aux_buttons_div : (this._aux_buttons_div = this.buttons_div.build("div")); }
CalendarDateSelect.prototype.initButtonsDivWithCancel = function() {
  this.initButtonsDivWithoutCancel();
  elements = []
  if (this.options.get("clear")) elements.push(Element.build("a", {
    innerHTML: _translations["Clear"],
    href: "#",
    onclick: function() { this.clearSelectedDate(); return false;}.bind(this)
  }))
  if (this.options.get("cancel")) elements.push(Element.build("a", {
    innerHTML: _translations["Cancel"],
    href: "#",
    onclick: function() { this.cancel(); return false;}.bind(this)
  }))
  for (x=0; x < elements.length; x++) {
    if (x>=1) this.aux_buttons_div().build("span", {innerHTML: " "})
    console.log((elements[x]))
    this.aux_buttons_div().appendChild(elements[x]);
  }
}
alias_method_chain(CalendarDateSelect.prototype, "initButtonsDiv", "Cancel")
CalendarDateSelect.prototype.initializeWithStashOriginalValue = function(target_element, options) {
  this.original_value = $F(target_element);
  return this.initializeWithoutStashOriginalValue(target_element, options);
}
alias_method_chain(CalendarDateSelect.prototype, "initialize", "StashOriginalValue");
CalendarDateSelect.prototype.cancel = function() {
  this.target_element.value = this.original_value; 
  this.parseDate();
  this.clearSelectedClass();
  this.updateSelectedDate({})
  this.closeUnlessEmbedded();
}
CalendarDateSelect.prototype.clearSelectedDate = function() {
  this.target_element.value = ""; 
  this.clearSelectedClass();
  this.selection_made = false;     
  this.closeUnlessEmbedded();
}
CalendarDateSelect.prototype.closeUnlessEmbedded = function() { if (! this.options.get("embedded")) this.close(); }
