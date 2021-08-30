window.addEventListener("load", function(event) {
    const tipo = localStorage.getItem('tipo');
    if(tipo){
        if(tipo!='paciente'){
            window.location.href='dashboardPsicologo.html';
        }
    }else{
        window.location.href='login.html';
    }
});