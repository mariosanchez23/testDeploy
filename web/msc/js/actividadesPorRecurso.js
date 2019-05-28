/*
// Cargamos datos para Carga Actividades
var actividadesData={};
loadJSON("api/recursos/98/actividades").then(function(results) {
    actividadesData=results;
    //populateTabla();
});


function populateTabla() {
    $('#tablaActividades').bootstrapTable({
        data: actividadesData
    });
    
}
*/

// FUNCTIONS TO CREATE GRAPHS

// GENERAL FUNCTIONS 


function loadJSON(url) {
    return fetch(url,{credentials: 'same-origin'})
            .then(function (response) {
                return response.json();

             })
            .then(function (data) {
                console.log('JSON from "' + url + '" parsed successfully!');
                console.log(data.children);
                return data.children;
            })
            .catch(function (error) {
                console.log(error.message);
            });
    
}

