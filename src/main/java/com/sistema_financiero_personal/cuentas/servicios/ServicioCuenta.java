package com.sistema_financiero_personal.cuentas.servicios;

import com.sistema_financiero_personal.cuentas.daos.DAOCuenta;
import com.sistema_financiero_personal.cuentas.modelos.Cuenta;
import com.sistema_financiero_personal.cuentas.modelos.TipoCuenta;
import com.sistema_financiero_personal.movimiento.servicios.ServicioCartera;

import java.util.List;

public class ServicioCuenta {
    private DAOCuenta daoCuenta;
    private ServicioCartera servicioCartera;

    public ServicioCuenta(DAOCuenta daoCuenta) {
        this.daoCuenta = daoCuenta;
    }

    public ServicioCuenta() {
        daoCuenta = new DAOCuenta();
        servicioCartera = new ServicioCartera();
    }

    public ServicioCuenta(DAOCuenta daoCuenta, ServicioCartera servicioCartera) {
        this.daoCuenta = daoCuenta;
        this.servicioCartera = servicioCartera;
    }

    public void crearCuenta(Cuenta cuenta) {
        validarObligatorios(cuenta);

        if (!validarSaldoInicial(cuenta.getMonto())) {
            throw new IllegalArgumentException("El saldo inicial debe ser mayor que cero");
        }

        if (existeCuentaDuplicada(cuenta.getNombre().trim(), cuenta.getTipo(), cuenta.getCartera().getId())) {
            throw new IllegalStateException("Ya existe una cuenta con el mismo nombre y tipo en esta cartera");
        }

        daoCuenta.crear(cuenta);
    }

    public boolean existeCuentaDuplicada(String nombre, TipoCuenta tipo, Long carteraId) {
        return daoCuenta.existeCuentaPorNombreYTipo(nombre.trim(), tipo, carteraId);
    }


    public Cuenta buscarCuenta(Long id) {
        return daoCuenta.buscarPorId(id);
    }

    public boolean validarSaldoInicial(double saldo) {
        if (saldo <= 0) {
            return false;
        }
        double centavos = redondearMonto(saldo);
        return Double.compare(saldo, centavos) == 0;
    }

    public void validarObligatorios(Cuenta cuenta) {
        if (cuenta == null ||
                cuenta.getNombre() == null ||
                cuenta.getNombre().isBlank() ||
                cuenta.getTipo() == null ||
                cuenta.getCartera() == null) {
            throw new IllegalArgumentException("Todos los campos deben ser llenados");
        }
    }
    
    public List<Cuenta> listarCuentasPorCartera(Long id) {
        return daoCuenta.listarPorCartera(id);
    }

    public boolean existe(Long cuentaId) {
        return daoCuenta.existe(cuentaId);
    }

    public void ajustarMonto(Long cuentaId, double cambio) {
        Cuenta cuenta = buscarCuenta(cuentaId);
        if (cuenta == null) {
            throw new IllegalArgumentException("La cuenta con ID " + cuentaId + " no existe");
        }
        double nuevoMonto = calcularSaldoDespuesCambio(cuenta.getMonto(), cambio);
        cuenta.setMonto(nuevoMonto);
        daoCuenta.actualizar(cuenta);

        servicioCartera.recalcularSaldo(cuenta.getCartera().getId());
    }

    public static boolean verificarSaldoCero(Cuenta cuenta, double gasto) {
        if (cuenta == null) throw new IllegalArgumentException("La cuenta no puede ser nula");
        if (gasto < 0) throw new IllegalArgumentException("El gasto debe ser positivo");
        double resultante = cuenta.getMonto() - gasto;
        if (resultante < 0) return false;
        cuenta.setMonto(resultante);
        return Double.compare(resultante, 0.0) == 0;
    }


    public double obtenerMonto(Long cuentaId) {
        return daoCuenta.obtenerMonto(cuentaId);
    }

    public double calcularSaldoDespuesCambio(double saldoActual, double cambio) {
        double nuevoSaldo = saldoActual + cambio;
        if (nuevoSaldo < 0) {
            throw new IllegalArgumentException(
                    String.format("Saldo insuficiente. Saldo actual: %.2f, cambio solicitado: %.2f",
                            saldoActual, cambio)
            );
        }
        return nuevoSaldo;
    }

    public double redondearMonto(double monto) {
        return Math.round(monto * 100.0) / 100.0;
    }

}