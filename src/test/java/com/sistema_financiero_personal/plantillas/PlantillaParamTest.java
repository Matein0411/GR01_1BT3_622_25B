package com.sistema_financiero_personal.plantillas;

import com.sistema_financiero_personal.plantillas.servicios.ServicioPlantilla;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.util.Arrays;
import java.util.Collection;

import static org.junit.Assert.assertThrows;

@RunWith(Parameterized.class)
public class PlantillaParamTest {

    private ServicioPlantilla servicioPlantilla;

    @Parameterized.Parameter(0)
    public String tipo;

    @Parameterized.Parameter(1)
    public Class<? extends Throwable> expectedException;

    @Before
    public void setUp() {
        servicioPlantilla = new ServicioPlantilla();
    }

    @Parameterized.Parameters(name = "{index}: tipo={0}")
    public static Collection<Object[]> data() {
        return Arrays.asList(new Object[][]{
                {"GASTO", null},
                {"INGRESO", null},
                {null, IllegalArgumentException.class},
                {"", IllegalArgumentException.class},
                {"   ", IllegalArgumentException.class},
                {"TIPO_INVALIDO", IllegalArgumentException.class},
                {"gasto", IllegalArgumentException.class},
                {"CUALQUIERCOSA", IllegalArgumentException.class}
        });
    }

    @Test
    public void testValidarTipo() {
        if (expectedException != null) {
            assertThrows(expectedException, () -> servicioPlantilla.validarTipo(tipo));
        } else {
            servicioPlantilla.validarTipo(tipo);
        }
    }
}

