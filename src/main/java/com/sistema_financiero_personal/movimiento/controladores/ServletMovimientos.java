package com.sistema_financiero_personal.movimiento.controladores;

import com.sistema_financiero_personal.cuentas.modelos.Cuenta;
import com.sistema_financiero_personal.cuentas.servicios.ServicioCuenta;
import com.sistema_financiero_personal.movimiento.modelos.CategoriaGasto;
import com.sistema_financiero_personal.movimiento.modelos.CategoriaIngreso;
import com.sistema_financiero_personal.movimiento.modelos.Movimiento;
import com.sistema_financiero_personal.movimiento.servicios.ServicioMovimiento;
import com.sistema_financiero_personal.plantillas.modelos.Plantilla;
import com.sistema_financiero_personal.plantillas.servicios.ServicioPlantilla;
import com.sistema_financiero_personal.usuario.modelos.Usuario;
import com.sistema_financiero_personal.comun.utilidades.mensajes.MensajeUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/movimientos")
public class ServletMovimientos extends HttpServlet {

    private ServicioMovimiento servicioMovimiento;
    private ServicioCuenta servicioCuenta;
    private ServicioPlantilla servicioPlantilla;

    @Override
    public void init() {
        this.servicioMovimiento = new ServicioMovimiento();
        this.servicioCuenta = new ServicioCuenta();
        this.servicioPlantilla = new ServicioPlantilla();
    }

    // Constructor para inyección en tests
    public ServletMovimientos(ServicioMovimiento servicioMovimiento,
                              ServicioCuenta servicioCuenta,
                              ServicioPlantilla servicioPlantilla) {
        this.servicioMovimiento = servicioMovimiento;
        this.servicioCuenta = servicioCuenta;
        this.servicioPlantilla = servicioPlantilla;
    }

    public ServletMovimientos() {
        // Constructor por defecto para el contenedor
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar sesión
        Usuario usuario = obtenerUsuarioSesion(request);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/ingreso");
            return;
        }

        HttpSession session = request.getSession();

        MensajeUtil.obtenerYLimpiarMensajes(request);

        Movimiento movimientoDesdePlantilla = (Movimiento) session.getAttribute("movimientoDesdePlantilla");
        String plantillaAplicada = (String) session.getAttribute("plantillaAplicada");

        if (movimientoDesdePlantilla != null) {
            request.setAttribute("movimientoPrecargado", movimientoDesdePlantilla);

            // Limpiar de la sesión
            session.removeAttribute("movimientoDesdePlantilla");
            session.removeAttribute("plantillaAplicada");
        }

        // Obtener las cuentas del usuario desde su cartera
        List<Cuenta> listaCuentas = servicioCuenta.listarCuentasPorCartera(usuario.getCartera().getId());

        // Verificar si el usuario tiene cuentas
        if (listaCuentas == null || listaCuentas.isEmpty()) {
            MensajeUtil.agregarAdvertencia(session,
                    "No tienes cuentas creadas. Debes crear al menos una cuenta antes de registrar movimientos.");
        }

        List<Plantilla> listaPlantillas = obtenerPlantillasActivas(usuario.getId());

        request.setAttribute("cuentas", listaCuentas);
        request.setAttribute("plantillas", listaPlantillas);
        request.getRequestDispatcher("/movimiento/VistaMovimientos.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar sesión
        Usuario usuario = obtenerUsuarioSesion(request);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/ingreso");
            return;
        }

        HttpSession session = request.getSession();

        String tipo = request.getParameter("tipo"); // INGRESO | GASTO
        String montoStr = request.getParameter("monto");
        String descripcion = request.getParameter("descripcion");
        String categoriaStr = request.getParameter("categoria");
        String cuentaIdStr = request.getParameter("cuentaId");

        // Validación de campos obligatorios
        if (isBlank(tipo) || isBlank(montoStr) || isBlank(descripcion) ||
                isBlank(categoriaStr) || isBlank(cuentaIdStr)) {
            MensajeUtil.agregarError(session, "Todos los campos deben ser llenados");
            response.sendRedirect(request.getContextPath() + "/movimientos");
            return;
        }

        try {
            double monto = Double.parseDouble(montoStr);
            Long cuentaId = Long.parseLong(cuentaIdStr);

            // Validación de monto positivo
            if (monto <= 0) {
                MensajeUtil.agregarError(session, "Monto inválido. Debe ser mayor a cero");
                response.sendRedirect(request.getContextPath() + "/movimientos");
                return;
            }

            // Verificar que la cuenta existe y pertenece al usuario
            Cuenta cuenta = servicioCuenta.buscarCuenta(cuentaId);
            if (cuenta == null) {
                MensajeUtil.agregarError(session, "La cuenta seleccionada no existe");
                response.sendRedirect(request.getContextPath() + "/movimientos");
                return;
            }

            // Verificar que la cuenta pertenece a la cartera del usuario
            if (!cuenta.getCartera().getId().equals(usuario.getCartera().getId())) {
                MensajeUtil.agregarError(session, "No tienes permiso para realizar movimientos en esta cuenta");
                response.sendRedirect(request.getContextPath() + "/movimientos");
                return;
            }

            // Registrar el movimiento según el tipo
            if ("INGRESO".equalsIgnoreCase(tipo)) {
                CategoriaIngreso categoriaIngreso = CategoriaIngreso.valueOf(categoriaStr.toUpperCase());
                servicioMovimiento.registrarIngreso(cuentaId, monto, descripcion, categoriaIngreso);
                MensajeUtil.agregarExito(session, "Ingreso registrado exitosamente en la cuenta: " + cuenta.getNombre());

            } else if ("GASTO".equalsIgnoreCase(tipo)) {
                CategoriaGasto categoriaGasto = CategoriaGasto.valueOf(categoriaStr.toUpperCase());
                servicioMovimiento.registrarGasto(cuentaId, monto, descripcion, categoriaGasto);
                MensajeUtil.agregarExito(session, "Gasto registrado exitosamente en la cuenta: " + cuenta.getNombre());

            } else {
                MensajeUtil.agregarError(session, "Tipo de movimiento no válido");
                response.sendRedirect(request.getContextPath() + "/movimientos");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (NumberFormatException e) {
            MensajeUtil.agregarError(session, "Error: El monto o ID de cuenta no es un número válido");
            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (IllegalArgumentException e) {
            // Captura errores como: saldo insuficiente, categoría inválida, etc.
            MensajeUtil.agregarError(session, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (Exception e) {
            MensajeUtil.agregarError(session, "Error al registrar el movimiento: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/movimientos");
        }
    }

    /**
     * Obtiene las plantillas activas del usuario
     */
    private List<Plantilla> obtenerPlantillasActivas(Long usuarioId) {
        try {
            // Aquí debes implementar el método en DAOPlantilla para listar por usuario
            // Por ahora retorna una lista vacía para evitar errores
            return servicioPlantilla.listarPlantillasPorUsuario(usuarioId);
        } catch (Exception e) {
            return List.of(); // Retorna lista vacía en caso de error
        }
    }

    /**
     * Verifica si una cadena está vacía o es nula
     */
    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    /**
     * Obtiene el usuario de la sesión actual
     */
    private Usuario obtenerUsuarioSesion(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (Usuario) session.getAttribute("usuario");
        }
        return null;
    }
}