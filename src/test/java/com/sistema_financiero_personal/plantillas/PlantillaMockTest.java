package com.sistema_financiero_personal.plantillas;

import com.sistema_financiero_personal.movimiento.modelos.*;
import com.sistema_financiero_personal.plantillas.daos.DAOPlantilla;
import com.sistema_financiero_personal.plantillas.servicios.ServicioPlantilla;
import com.sistema_financiero_personal.plantillas.modelos.Plantilla;
import com.sistema_financiero_personal.usuario.daos.DAOUsuario;
import com.sistema_financiero_personal.usuario.modelos.Usuario;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import static org.junit.Assert.*;

import static org.mockito.Mockito.*;


public class PlantillaMockTest {

    private DAOPlantilla daoPlantillaMock;
    private DAOUsuario daoUsuarioMock;
    private ServicioPlantilla servicioPlantillas;

    @BeforeEach
    void setUp() {
        daoPlantillaMock = Mockito.mock(DAOPlantilla.class);
        daoUsuarioMock = Mockito.mock(DAOUsuario.class);
        servicioPlantillas = new ServicioPlantilla(daoPlantillaMock, daoUsuarioMock);
    }

    @Test
    public void given_data_when_create_template_then_delegates_to_dao() {
        Long usuarioId = 1L;
        String nombre = "Pago Arriendo";
        double monto = 35.0;
        String tipo = "GASTO";
        CategoriaGasto categoriaGasto = CategoriaGasto.SERVICIOS;

        Plantilla plantilla = new Plantilla();
        plantilla.setNombre(nombre);
        plantilla.setMonto(monto);
        plantilla.setTipo(tipo);
        plantilla.setCategoria(categoriaGasto.name());

        Usuario usuarioEsperado = new Usuario();
        usuarioEsperado.setId(usuarioId);

        when(daoUsuarioMock.buscarPorId(usuarioId)).thenReturn(usuarioEsperado);
        doNothing().when(daoPlantillaMock).crear(plantilla);
        when(daoPlantillaMock.existePlantillaPorNombre(nombre, usuarioId)).thenReturn(false);

        servicioPlantillas.crearPlantilla(plantilla, usuarioId);

        verify(daoUsuarioMock, times(1)).buscarPorId(usuarioId);
    }

    @Test
    public void given_data_when_delete_template_then_delegates_to_dao() {
        Long plantilla_Id = 1L;

        doNothing().when(daoPlantillaMock).borrar(plantilla_Id);

        servicioPlantillas.eliminarPlantilla(plantilla_Id);

        verify(daoPlantillaMock, times(1)).borrar(plantilla_Id);
    }

}
