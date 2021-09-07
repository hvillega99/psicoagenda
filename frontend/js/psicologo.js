
function borrarL() {
    localStorage.removeItem('tipo');
    localStorage.removeItem('id');
    window.location.href='login.html';
  }

const getInfo = async () => {
    const uri = `http://127.0.0.1:4567/psicologos/${localStorage.getItem("id")}`;
    const response = await fetch(uri);
    const result = response.json();
    return result;
}

const getCitas = async () => {
    const uri = `http://127.0.0.1:4567/citasPorPsicologo/${localStorage.getItem("id")}`;
    const response = await fetch(uri);
    const result = response.json();
    return result;
}

const getTurnos = async () => {
  const uri = `http://127.0.0.1:4567/turnosDisponibles/${localStorage.getItem("id")}`;
  const response = await fetch(uri);
  const result = response.json();
  return result;
}

const showAlertMessage = (message, tipoAlerta) =>{
  const divMessage = document.getElementById('message');
  divMessage.innerHTML =`<div class="alert alert-${tipoAlerta}" role="alert">${message}</div>`;
  setTimeout(()=>{
      divMessage.innerHTML = '';
  },5000);
}

const getFecha = () => {
  const fecha = new Date();
  const dateItems = fecha.toLocaleDateString().split('/');
  return `${dateItems[2]}-${dateItems[1].length < 2? '0'+dateItems[1]:dateItems[1]}-${dateItems[0].length < 2? '0'+dateItems[0]:dateItems[0]}`;
}

const renderCitas = (citas, fecha) => {
  const result = citas.filter(cita => cita.fecha == fecha && cita.estado == 'No iniciada');
  result.sort((x, y) =>{
    return ((x.hora < y.hora) ? -1 : ((x.hora > y.hora) ? 1 : 0));
  });
  
  const divPacientes = document.getElementById('lista-pacientes')

  if(result.length > 0){

    let lista = `<div class="btn-group d-flex flex-column" 
                  role="group" aria-label="Basic radio toggle button group">`;

    result.forEach(item => {
      lista += `<input type="radio" class="btn-check" name="btnradio" id="cita-${item.id}" 
                autocomplete="off" onclick=renderCitaDetalles(${item.id}) cheked>
                <label class="btn btn-outline-primary" for="cita-${item.id}">
                  ${item.nombreCompleto}
                </label>`
    })
    
    divPacientes.innerHTML = lista + '</div>';

  }else{

    divPacientes.textContent = 'No hay pacientes agendados';

  }
    
}

const renderCitaDetalles = async (idCita) => {
  const divDetalles = document.getElementById('detalles-cita');
  const citas = await getCitas();
  console.log(citas)
  const targetCita = citas.find(cita => cita.id == idCita);

  console.log(idCita)

  divDetalles.innerHTML = `<div class="card text-center">
                            <div class="card-header">
                              Información de la cita
                            </div>
                            <div class="card-body">
                              <h5 class="card-title">Paciente: ${targetCita.nombreCompleto}</h5>
                              <p class="card-text">
                                Fecha: ${targetCita.fecha}
                                Hora: ${targetCita.hora}
                              </p>
                              <button class="btn btn-primary">Iniciar cita</button>
                              <button class="btn btn-secondary">Ver historia clínica</button>
                            </div>
                          </div>`;

}

const showTurnos = (turnos) => {

  const turnosDisp = turnos.filter(turno => turno.estado == "disponible");
  const divTurnos = document.getElementById("turnos-disponibles");
  let elements = '';
  if(turnosDisp.length > 0){
    turnosDisp.forEach(turno => {
      elements += `<div class="card card-body text-center" id="turno-${turno.id}">
                    <p class="card-text">
                      Fecha: ${turno.fecha}
                    </p>
                    <p class="card-text">
                      Hora: ${turno.hora}
                    </p>
                    <p class ="card-text">
                      Estado: ${turno.estado}
                    </p>
                  </div>`;
    })
  }
  else{
    divHistorial.innerHTML = '<h3 class="text-center">No hay información para mostrar</h3>';
  }
  divTurnos.innerHTML = elements;
}

const crearTurnos = async (fecha, hora, estado, idPsicologo) => {

  const uri = `http://127.0.0.1:4567/turnos`;

  const newTurno = {
    'fecha': fecha,
    'hora': hora,
    'estado': estado,
    'idPsicologo': idPsicologo
  }

  fetch(uri, {
    method: 'POST',
    mode: 'no-cors', 
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(newTurno)
  })
  
  .catch(e => {
    return undefined;
  })

  return newTurno;

}


window.addEventListener("load", async(event) => {
    const tipo = localStorage.getItem('tipo');
    if(tipo){
        if(tipo!='psicologo'){
            window.location.href='dashboardPaciente.html';
        }
        else{
            const psicologo = await getInfo();
            document.getElementById('saludo').textContent = `Bienvenido ${psicologo[0].nombreCompleto}`;
            document.getElementById('nombre').textContent = `${psicologo[0].nombreCompleto}`;

            const citas = await getCitas();
            const turnos = await getTurnos();

            renderCitas(citas, getFecha());
            showTurnos(turnos);

            document.getElementById('fecha-citas').value = getFecha();

            const result = citas.find(item => item.estado == 'No iniciada')

            const divStatus = document.getElementById('status');
            const divInfo = document.getElementById('cita-info');

            if(result){
                document.getElementById('status').textContent = 'Usted tiene una cita agendada';

                const divInfo = document.getElementById('cita-info');
                divInfo.innerHTML = `<div class="card text-center">
                <div class="card-header">
                  Información de la cita
                </div>
                <div class="card-body">
                  <h5 class="card-title">Paciente: ${result.nombreCompleto}</h5>
                  <p class="card-text">
                    Fecha: ${result.fecha}
                    Hora: ${result.hora}
                  </p>
                </div>
              </div>`

            }else{
                document.getElementById('status').textContent = 'Actualmente no tiene una cita agendada';
            }
            
        }
    }
    else{
        window.location.href='login.html';
    }
});

const setInvisible = () => {
    const elements = document.getElementsByClassName('option-panel');

    for(let i=0; i<elements.length; i++){
      elements[i].style.display='none';
    }
}

document.getElementById('crear-button')
.addEventListener('click', async (e) =>{
  e.preventDefault();
  const fecha = document.getElementById('fecha').value;
  const hora = document.getElementById('hora').value;
  const estado = "disponible";
  const idPsicologo = localStorage.getItem("id");
  const turno = await crearTurnos(fecha, hora, estado, idPsicologo);

  if(turno != undefined){
    showAlertMessage("Turno creado con exito", 'success');
  }
  else{
    showAlertMessage("Error al crear un turno", 'danger');
  }

});

document.getElementById('fecha-citas')
.addEventListener('change', async (e) => {
  console.log(e.target.value);
  const citas = await getCitas();
  renderCitas(citas, e.target.value);
  document.getElementById('detalles-cita').innerHTML='';
});

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

document.getElementById('tab-creart')
.addEventListener('click', e => {
  setInvisible();
  document.getElementById('crear').style.display='block';
});

document.getElementById('tab-citas')
.addEventListener('click', e =>{
  setInvisible();
  document.getElementById('citas').style.display='block';
});