package com.sistema_financiero_personal.plantillas;

import com.sistema_financiero_personal.cuentas.modelos.Cuenta;
import com.sistema_financiero_personal.movimiento.modelos.CategoriaGasto;
import com.sistema_financiero_personal.movimiento.modelos.CategoriaIngreso;
import com.sistema_financiero_personal.plantillas.modelos.Plantilla;
import com.sistema_financiero_personal.plantillas.servicios.ServicioPlantilla;
import com.sistema_financiero_personal.usuario.modelos.Usuario;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class PlantillaFiltrosTest {

    private static Plantilla plantilla1;
    private static Plantilla plantilla2;
    private static Plantilla plantilla3;
    private static ServicioPlantilla servicioPlantilla;

    @Before
    public void setUp() {
        servicioPlantilla = new ServicioPlantilla();

        plantilla1 = new Plantilla();
        plantilla1.setNombre("test bus 1");
        plantilla1.setCategoriaGasto(CategoriaGasto.SERVICIOS);

        plantilla2 = new Plantilla();
        plantilla2.setNombre("test bus");
        plantilla2.setCategoriaIngreso(CategoriaIngreso.ABONO_PRESTAMO);

        plantilla3 = new Plantilla();
        plantilla3.setNombre("test metro");
        plantilla3.setCategoriaIngreso(CategoriaIngreso.ABONO_PRESTAMO);

        servicioPlantilla.guardarEnLista(plantilla1);
        servicioPlantilla.guardarEnLista(plantilla2);
        servicioPlantilla.guardarEnLista(plantilla3);
    }

    @Test
    public void given_name_to_search_when_search_the_name_then_ok(){

        List<Plantilla> plantillasEncontradas = servicioPlantilla.buscarPorNombre( "bus");

        assertEquals(2, plantillasEncontradas.size());
        assertTrue(plantillasEncontradas.stream()
                .allMatch(p -> p.getNombre().contains("bus")));
    }

    @Test
    public void given_category_to_search_when_search_it_then_ok(){

        List<Plantilla> plantillasEncontradas = servicioPlantilla.buscarPorCategoriaGasto(CategoriaGasto.SERVICIOS);

        assertEquals(1, plantillasEncontradas.size());
        assertTrue(plantillasEncontradas.stream()
                .allMatch(p -> p.getCategoria().contains(CategoriaGasto.SERVICIOS.toString())));
    }

    @Test
    public void given_type_to_search_when_search_it_then_ok(){

        List<Plantilla> plantillasEncontradas = servicioPlantilla.buscarPorTipo("GASTO");

        assertEquals(1, plantillasEncontradas.size());
        assertTrue(plantillasEncontradas.stream()
                .allMatch(p -> p.getTipo().contains("GASTO")));
    }

}
