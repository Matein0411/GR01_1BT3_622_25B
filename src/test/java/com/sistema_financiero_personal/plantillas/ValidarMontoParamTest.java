package com.sistema_financiero_personal.plantillas;

import com.sistema_financiero_personal.plantillas.servicios.ServicioPlantilla;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.util.Arrays;
import java.util.Collection;

import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;

@RunWith(Parameterized.class)
public class ValidarMontoParamTest {

    private ServicioPlantilla servicioPlantilla;

    @Parameterized.Parameter(0)
    public double montoInvalido;

    @Before
    public void setUp() {
        servicioPlantilla = new ServicioPlantilla();
    }

    @Parameterized.Parameters(name = "{index}: monto={0} debería ser inválido")
    public static Collection<Object[]> data() {
        return Arrays.asList(new Object[][]{
                {Double.NaN},
                {0.0},
                {-10.0},
                {1_000_000.00}
        });
    }

    @Test
    public void given_invalid_amount_when_validate_then_throw_exception() {
        IllegalArgumentException ex = assertThrows(
                IllegalArgumentException.class,
                () -> servicioPlantilla.validarMonto(montoInvalido)
        );

        assertTrue(
                "El mensaje debe ser: 'Monto no válido' (monto=" + montoInvalido + ")",
                ex.getMessage().contains("Monto no válido")
        );
    }
}
