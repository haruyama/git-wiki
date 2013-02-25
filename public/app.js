"use strict";

function clearField(e) {
    if (e.cleared) { return; }
    e.cleared = true;
    e.value = '';
    e.style.color = '#333';
}
