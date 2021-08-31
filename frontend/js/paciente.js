function borrarL() {
  localStorage.removeItem('tipo');
  localStorage.removeItem('id');
  window.location.href='login.html';
}



const getInfo = async () => {
    const uri = `http://127.0.0.1:4567/pacientes/${localStorage.getItem("id")}`;
    const response = await fetch(uri);
    const result = response.json();
    return result;
}

const getCitas = async () =>{
    const uri = `http://127.0.0.1:4567/citasPorPaciente/${localStorage.getItem("id")}`;
    const response = await fetch(uri);
    const result = response.json();
    return result;
}

const showCitasAnteriores = (citas) => {
    const citasAnteriores = citas.filter(cita => cita.estado == 'Finalizada');
    const divHistorial = document.getElementById('historial');

    if(citasAnteriores.length > 0){
        let table = `<table class="table">
                        <thead>
                            <tr>
                                <th scope="col">Psicólogo</th>
                                <th scope="col">Fecha</th>
                                <th scope="col">Hora</th>
                            </tr>
                        </thead>
                        <tbody>`;

        citasAnteriores.forEach(element => {
            table +=`<tr>
                        <td>${element.nombreCompleto}</td>
                        <td>${element.fecha}</td>
                        <td>${element.hora}</td>
                    </tr>`;
        });

        table += `</tbody></table>`;

        divHistorial.innerHTML ='<h3 class="text-center">Historial de citas</h3>' + table;
    }else{
        divHistorial.innerHTML = '<h3 class="text-center">No hay información para mostrar</h3>';
    }
    
}

window.addEventListener("load", async (event) => {
    const tipo = localStorage.getItem('tipo');
    if(tipo){
        if(tipo!='paciente'){
            window.location.href='dashboardPsicologo.html';
        }else{
            const paciente = await getInfo();
            document.getElementById('saludo').textContent = `Bienvenido ${paciente[0].nombreCompleto}`;
            
            const citas = await getCitas();

            showCitasAnteriores(citas);

            const result = citas.find(item => item.estado == 'No iniciada')

            if(result){
                document.getElementById('status').textContent = 'Usted tiene una cita agendada';

                const divInfo = document.getElementById('cita-info');
                divInfo.innerHTML = `<div class="card text-center">
                <div class="card-header">
                  Información de la cita
                </div>
                <div class="card-body">
                  <h5 class="card-title">Psicólogo: ${result.nombreCompleto}</h5>
                  <p class="card-text">
                    Fecha: ${result.fecha}
                    Hora: ${result.hora}
                  </p>
                  <button class="btn btn-danger">Cancelar</button>
                </div>
              </div>`

            }else{
                document.getElementById('status').textContent = 'Actualmente no tiene una cita agendada';
            }
        }
    }else{
        window.location.href='login.html';
    }
});


const setInvisible = () => {
    const elements = document.getElementsByClassName('option-panel');

    for(let i=0; i<elements.length; i++){
      elements[i].style.display='none';
    }
}
  
document.getElementById('tab-inicio')
.addEventListener('click', e =>{
  setInvisible();
  document.getElementById('inicio').style.display='block';
});
  
document.getElementById('tab-agendar')
.addEventListener('click', e =>{
  setInvisible();
  document.getElementById('agendar').style.display='block';
});
  
document.getElementById('tab-historial')
.addEventListener('click', e =>{
  setInvisible();
  document.getElementById('historial').style.display='block';
});