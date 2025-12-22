package com.sistema_financiero_personal.plantillas.controladores;

import com.sistema_financiero_personal.cuentas.modelos.Cuenta;
import com.sistema_financiero_personal.cuentas.servicios.ServicioCuenta;
import com.sistema_financiero_personal.movimiento.modelos.CategoriaGasto;
import com.sistema_financiero_personal.movimiento.modelos.CategoriaIngreso;
import com.sistema_financiero_personal.movimiento.modelos.Movimiento;
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

/**
 * Servlet para gestionar plantillas de movimientos
 * - GET  /plantillas/nuevo  -> Muestra formulario de creación
 * - POST /plantillas/nuevo  -> Procesa creación
 * - GET  /plantillas/editar -> Muestra formulario de edición
 * - POST /plantillas/editar -> Procesa edición
 * - POST /plantillas/eliminar -> Elimina plantilla
 * - GET  /plantillas/aplicar -> Aplica plantilla a formulario de movimientos
 * - GET  /plantillas/duplicar -> Duplica plantilla existente
 */
@WebServlet(urlPatterns = {
        "/plantillas/nuevo",
        "/plantillas/editar",
        "/plantillas/eliminar",
        "/plantillas/aplicar",
        "/plantillas/buscar",
        "/plantillas/duplicar"
})
public class ServletPlantilla extends HttpServlet {

    private ServicioPlantilla servicioPlantilla;
    private ServicioCuenta servicioCuenta;

    @Override
    public void init() {
        this.servicioPlantilla = new ServicioPlantilla();
        this.servicioCuenta = new ServicioCuenta();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuario = obtenerUsuarioSesion(request);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/ingreso");
            return;
        }

        String path = request.getServletPath();

        switch (path) {
            case "/plantillas/nuevo":
                mostrarFormulario(request, response, usuario, null);
                break;
            case "/plantillas/editar":
                mostrarFormularioEdicion(request, response, usuario);
                break;
            case "/plantillas/aplicar":
                aplicarPlantilla(request, response, usuario);
                break;
            case "/plantillas/buscar":
                buscarPlantillas(request, response, usuario);
                break;
            case "/plantillas/duplicar":
                duplicarPlantilla(request, response, usuario);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/movimientos");
                break;
        }
    }

    private void buscarPlantillas(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        String nombre = request.getParameter("nombre");
        String tipo = request.getParameter("tipo");
        String categoria = request.getParameter("categoria");

        try {
            List<Cuenta> listaCuentas = servicioCuenta.listarCuentasPorCartera(usuario.getCartera().getId());
            request.setAttribute("cuentas", listaCuentas);

            if (listaCuentas == null || listaCuentas.isEmpty()) {
                HttpSession session = request.getSession();
                MensajeUtil.agregarAdvertencia(session,
                        "No tienes cuentas creadas. Debes crear al menos una cuenta antes de registrar movimientos.");
            }

            List<Plantilla> plantillasFiltradas = servicioPlantilla.buscarPlantillasConFiltros(
                    usuario.getId(), nombre, tipo, categoria
            );

            // Guardar filtros para mantenerlos en el formulario
            request.setAttribute("filtroNombre", nombre != null ? nombre : "");
            request.setAttribute("filtroTipo", tipo != null ? tipo : "");
            request.setAttribute("filtroCategoria", categoria != null ? categoria : "");
            request.setAttribute("plantillas", plantillasFiltradas);

            // Forward a la vista
            request.getRequestDispatcher("/movimiento/VistaMovimientos.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            HttpSession session = request.getSession();
            MensajeUtil.agregarError(session, "Error al buscar plantillas: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/movimientos");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuario = obtenerUsuarioSesion(request);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/ingreso");
            return;
        }

        String path = request.getServletPath();

        switch (path) {
            case "/plantillas/nuevo":
                procesarGuardado(request, response, usuario, null);
                break;
            case "/plantillas/editar":
                procesarGuardado(request, response, usuario, request.getParameter("id"));
                break;
            case "/plantillas/eliminar":
                eliminarPlantilla(request, response, usuario);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/movimientos");
                break;
        }
    }

    /**
     * Muestra el formulario de plantilla (creación o edición)
     */
    private void mostrarFormulario(HttpServletRequest request, HttpServletResponse response,
                                   Usuario usuario, Plantilla plantilla)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        MensajeUtil.obtenerYLimpiarMensajes(request);

        List<Cuenta> listaCuentas = servicioCuenta.listarCuentasPorCartera(usuario.getCartera().getId());
        request.setAttribute("cuentas", listaCuentas);

        // Verificar si hay una plantilla duplicada en sesión
        if (plantilla == null) {
            Plantilla plantillaDuplicada = (Plantilla) session.getAttribute("plantillaDuplicada");
            if (plantillaDuplicada != null) {
                plantilla = plantillaDuplicada;
                session.removeAttribute("plantillaDuplicada");
            }
        }

        if (plantilla != null) {
            request.setAttribute("plantilla", plantilla);
        }

        request.getRequestDispatcher("/plantillas/VistaFormPlantilla.jsp").forward(request, response);
    }

    /**
     * Muestra el formulario para editar una plantilla existente
     */
    private void mostrarFormularioEdicion(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");

        if (isBlank(idStr)) {
            MensajeUtil.agregarError(session, "ID de plantilla no proporcionado");
            response.sendRedirect(request.getContextPath() + "/movimientos");
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            Plantilla plantilla = servicioPlantilla.buscarPorId(id);

            if (!validarPlantilla(plantilla, usuario, session, "editar")) {
                response.sendRedirect(request.getContextPath() + "/movimientos");
                return;
            }

            mostrarFormulario(request, response, usuario, plantilla);

        } catch (NumberFormatException e) {
            MensajeUtil.agregarError(session, "ID de plantilla inválido");
            response.sendRedirect(request.getContextPath() + "/movimientos");
        }
    }

    /**
     * Duplica una plantilla existente
     */
    private void duplicarPlantilla(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException, ServletException {

        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");

        if (isBlank(idStr)) {
            MensajeUtil.agregarError(session, "ID de plantilla no proporcionado");
            response.sendRedirect(request.getContextPath() + "/movimientos");
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            Plantilla original = servicioPlantilla.buscarPorId(id);

            if (!validarPlantilla(original, usuario, session, "duplicar")) {
                response.sendRedirect(request.getContextPath() + "/movimientos");
                return;
            }

            // Duplicar la plantilla
            Plantilla copia = servicioPlantilla.duplicarPlantilla(original);
            copia.setUsuario(usuario);

            // Guardar la copia en la sesión para precargar el formulario
            session.setAttribute("plantillaDuplicada", copia);

            // Mensaje informativo
            MensajeUtil.agregarInfo(session, "Duplicando plantilla " + original.getNombre() + ". Puedes modificar los datos antes de guardar.");

            // Redirigir al formulario de creación
            response.sendRedirect(request.getContextPath() + "/plantillas/nuevo");

        } catch (NumberFormatException e) {
            MensajeUtil.agregarError(session, "ID de plantilla inválido");
            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (Exception e) {
            MensajeUtil.agregarError(session, "Error al duplicar la plantilla: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/movimientos");
        }
    }

    /**
     * Procesa el guardado de una plantilla (creación o edición)
     */
    private void procesarGuardado(HttpServletRequest request, HttpServletResponse response,
                                  Usuario usuario, String idStr)
            throws IOException {

        HttpSession session = request.getSession();

        String nombre = request.getParameter("nombre");
        String tipo = request.getParameter("tipo");
        String montoStr = request.getParameter("monto");
        String categoriaStr = request.getParameter("categoria");
        String cuentaIdStr = request.getParameter("cuentaId");

        // Validación de campos obligatorios
        if (isBlank(nombre) || isBlank(tipo) || isBlank(montoStr) || isBlank(categoriaStr)) {
            MensajeUtil.agregarError(session, "Todos los campos obligatorios deben ser llenados");
            String redirectUrl = idStr != null ? "/plantillas/editar?id=" + idStr : "/plantillas/nuevo";
            response.sendRedirect(request.getContextPath() + redirectUrl);
            return;
        }

        try {
            double monto = Double.parseDouble(montoStr);

            // Determinar si es creación o edición
            Plantilla plantilla;
            boolean esEdicion = !isBlank(idStr);

            if (esEdicion) {
                Long id = Long.parseLong(idStr);
                plantilla = servicioPlantilla.buscarPorId(id);

                if (!validarPlantilla(plantilla, usuario, session, "editar")) {
                    response.sendRedirect(request.getContextPath() + "/movimientos");
                    return;
                }
            } else {
                plantilla = new Plantilla();
            }

            // Establecer datos básicos
            plantilla.setNombre(nombre.trim());
            plantilla.setTipo(tipo.toUpperCase());
            plantilla.setMonto(monto);
            plantilla.setActivo(true);

            // Establecer categoría según el tipo
            if (!establecerCategoria(plantilla, tipo, categoriaStr)) {
                MensajeUtil.agregarError(session, "Tipo de movimiento no válido");
                String redirectUrl = esEdicion ? "/plantillas/editar?id=" + idStr : "/plantillas/nuevo";
                response.sendRedirect(request.getContextPath() + redirectUrl);
                return;
            }

            // Asignar o limpiar cuenta
            if (!asignarCuenta(plantilla, cuentaIdStr, usuario, session)) {
                String redirectUrl = esEdicion ? "/plantillas/editar?id=" + idStr : "/plantillas/nuevo";
                response.sendRedirect(request.getContextPath() + redirectUrl);
                return;
            }

            // Guardar o actualizar
            if (esEdicion) {
                servicioPlantilla.actualizarPlantilla(plantilla);
                MensajeUtil.agregarExito(session, "Plantilla actualizada exitosamente");
            } else {
                servicioPlantilla.crearPlantilla(plantilla, usuario.getId());
                MensajeUtil.agregarExito(session, "Plantilla creada exitosamente");

                // Limpiar plantilla duplicada de la sesión si existe
                session.removeAttribute("plantillaDuplicada");
            }

            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (NumberFormatException e) {
            MensajeUtil.agregarError(session, "Error: Valores numéricos inválidos");
            String redirectUrl = idStr != null ? "/plantillas/editar?id=" + idStr : "/plantillas/nuevo";
            response.sendRedirect(request.getContextPath() + redirectUrl);

        } catch (IllegalArgumentException e) {
            MensajeUtil.agregarError(session, "Error: " + e.getMessage());
            String redirectUrl = idStr != null ? "/plantillas/editar?id=" + idStr : "/plantillas/nuevo";
            response.sendRedirect(request.getContextPath() + redirectUrl);

        } catch (Exception e) {
            String mensaje = idStr != null ? "actualizar" : "crear";
            MensajeUtil.agregarError(session,  e.getMessage());
            String redirectUrl = idStr != null ? "/plantillas/editar?id=" + idStr : "/plantillas/nuevo";
            response.sendRedirect(request.getContextPath() + redirectUrl);
        }
    }

    /**
     * Elimina una plantilla
     */
    private void eliminarPlantilla(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {

        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");

        if (isBlank(idStr)) {
            MensajeUtil.agregarError(session, "ID de plantilla no proporcionado");
            response.sendRedirect(request.getContextPath() + "/movimientos");
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            Plantilla plantilla = servicioPlantilla.buscarPorId(id);

            if (!validarPlantilla(plantilla, usuario, session, "eliminar")) {
                response.sendRedirect(request.getContextPath() + "/movimientos");
                return;
            }

            String nombrePlantilla = plantilla.getNombre();
            servicioPlantilla.eliminarPlantilla(id);

            MensajeUtil.agregarExito(session, "Plantilla eliminada exitosamente");
            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (NumberFormatException e) {
            MensajeUtil.agregarError(session, "ID de plantilla inválido");
            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (Exception e) {
            MensajeUtil.agregarError(session, "Error al eliminar la plantilla: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/movimientos");
        }
    }

    /**
     * Aplica una plantilla y redirige al formulario de movimientos
     */
    private void aplicarPlantilla(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {

        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");

        if (isBlank(idStr)) {
            MensajeUtil.agregarError(session, "ID de plantilla no proporcionado");
            response.sendRedirect(request.getContextPath() + "/movimientos");
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            Plantilla plantilla = servicioPlantilla.buscarPorId(id);

            if (!validarPlantilla(plantilla, usuario, session, "usar")) {
                response.sendRedirect(request.getContextPath() + "/movimientos");
                return;
            }

            Movimiento movimiento = servicioPlantilla.aplicarPlantilla(plantilla);

            session.setAttribute("movimientoDesdePlantilla", movimiento);
            session.setAttribute("plantillaAplicada", plantilla.getNombre());

            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (NumberFormatException e) {
            MensajeUtil.agregarError(session, "ID de plantilla inválido");
            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (IllegalStateException | IllegalArgumentException e) {
            MensajeUtil.agregarError(session, "Error al aplicar plantilla: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/movimientos");

        } catch (Exception e) {
            MensajeUtil.agregarError(session, "Error inesperado al aplicar plantilla: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/movimientos");
        }
    }

    /**
     * Valida que la plantilla existe y pertenece al usuario
     */
    private boolean validarPlantilla(Plantilla plantilla, Usuario usuario, HttpSession session, String accion) {
        if (plantilla == null) {
            MensajeUtil.agregarError(session, "Plantilla no encontrada");
            return false;
        }

        if (!plantilla.getUsuario().getId().equals(usuario.getId())) {
            MensajeUtil.agregarError(session, "No tienes permiso para " + accion + " esta plantilla");
            return false;
        }

        return true;
    }

    /**
     * Establece la categoría según el tipo de movimiento
     */
    private boolean establecerCategoria(Plantilla plantilla, String tipo, String categoriaStr) {
        try {
            if ("INGRESO".equalsIgnoreCase(tipo)) {
                CategoriaIngreso categoria = CategoriaIngreso.valueOf(categoriaStr.toUpperCase());
                plantilla.setCategoria(categoria.name());
                return true;
            } else if ("GASTO".equalsIgnoreCase(tipo)) {
                CategoriaGasto categoria = CategoriaGasto.valueOf(categoriaStr.toUpperCase());
                plantilla.setCategoria(categoria.name());
                return true;
            }
            return false;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    /**
     * Asigna una cuenta a la plantilla si se seleccionó una
     */
    private boolean asignarCuenta(Plantilla plantilla, String cuentaIdStr, Usuario usuario, HttpSession session) {
        if (isBlank(cuentaIdStr)) {
            plantilla.setCuenta(null);
            return true;
        }

        try {
            Long cuentaId = Long.parseLong(cuentaIdStr);
            Cuenta cuenta = servicioCuenta.buscarCuenta(cuentaId);

            if (cuenta == null) {
                MensajeUtil.agregarError(session, "La cuenta seleccionada no existe");
                return false;
            }

            if (!cuenta.getCartera().getId().equals(usuario.getCartera().getId())) {
                MensajeUtil.agregarError(session, "No tienes permiso para usar esta cuenta");
                return false;
            }

            plantilla.setCuenta(cuenta);
            return true;

        } catch (NumberFormatException e) {
            MensajeUtil.agregarError(session, "ID de cuenta inválido");
            return false;
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private Usuario obtenerUsuarioSesion(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (Usuario) session.getAttribute("usuario");
        }
        return null;
    }
}