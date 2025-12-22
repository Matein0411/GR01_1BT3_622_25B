<%--
    Vista: Formulario de Plantilla (Crear/Editar)
    Descripción: Formulario unificado para crear y editar plantillas de movimientos.
    CSS: style.css (global)
--%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ page import="com.sistema_financiero_personal.movimiento.modelos.CategoriaIngreso" %>
<%@ page import="com.sistema_financiero_personal.movimiento.modelos.CategoriaGasto" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<%-- Determinar si es modo crear o editar --%>
<c:set var="esEdicion" value="${plantilla != null && plantilla.id != null}" />
<c:set var="tituloAccion" value="${esEdicion ? 'Editar' : 'Nueva'}" />
<c:set var="urlAccion" value="${esEdicion ? '/plantillas/editar' : '/plantillas/nuevo'}" />
<c:set var="textoBoton" value="${esEdicion ? 'Guardar Cambios' : 'Guardar Plantilla'}" />

<jsp:include page="/comun/VistaHeader.jsp">
    <jsp:param name="pageTitle" value="${tituloAccion} Plantilla" />
</jsp:include>

<%-- Enlace al CSS Global (Formularios, Botones, Layout) --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">

<div class="page-header">
    <div style="display: flex; align-items: center; gap: 15px;">
        <a href="${pageContext.request.contextPath}/movimientos" style="text-decoration: none; color: #3498db;">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
        </a>
        <h1>${tituloAccion} Plantilla</h1>
    </div>
</div>

<jsp:include page="/comun/Mensajes.jsp" />

<%-- Este contenedor ahora usa los estilos de style.css --%>
<div class="form-container">
    <form class="plantilla-form" method="post" action="${pageContext.request.contextPath}${urlAccion}">

        <%-- Campo oculto con el ID (solo en modo edición) --%>
        <c:if test="${esEdicion}">
            <input type="hidden" name="id" value="${plantilla.id}" />
        </c:if>

        <div class="form-grid">
            <%-- Campo: Nombre de la Plantilla --%>
            <div class="form-group" style="grid-column: 1 / -1;">
                <label for="nombre">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                    </svg>
                    Nombre de la Plantilla *
                </label>
                <input
                        type="text"
                        id="nombre"
                        name="nombre"
                        value="${plantilla != null ? plantilla.nombre : param.nombre}"
                        placeholder="Ej: Pago de Alquiler, Salario Mensual, Compra de Supermercado"
                        required
                        maxlength="100"
                />
            </div>

            <%-- Campo: Cuenta --%>
            <div class="form-group">
                <label for="cuentaId">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect>
                        <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path>
                    </svg>
                    Cuenta (Opcional)
                </label>
                <select id="cuentaId" name="cuentaId">
                    <option value="">Sin cuenta predefinida</option>
                    <c:forEach var="cuenta" items="${cuentas}">
                        <option value="${cuenta.id}"
                                <c:choose>
                                    <c:when test="${plantilla != null && plantilla.cuenta != null && cuenta.id == plantilla.cuenta.id}">selected</c:when>
                                    <c:when test="${plantilla == null && cuenta.id == param.cuentaId}">selected</c:when>
                                </c:choose>>
                                ${cuenta.nombre} (${cuenta.tipo}) - $<fmt:formatNumber value="${cuenta.monto}" pattern="#,##0.00"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <%-- Campo: Tipo de Movimiento --%>
            <div class="form-group">
                <label for="tipo">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline>
                        <polyline points="17 6 23 6 23 12"></polyline>
                    </svg>
                    Tipo de Movimiento *
                </label>
                <select id="tipo" name="tipo" required>
                    <option value="">Seleccione un tipo</option>
                    <option value="INGRESO"
                            <c:if test="${(plantilla != null && plantilla.tipo == 'INGRESO') || (plantilla == null && param.tipo == 'INGRESO')}">selected</c:if>>
                        Ingreso
                    </option>
                    <option value="GASTO"
                            <c:if test="${(plantilla != null && plantilla.tipo == 'GASTO') || (plantilla == null && param.tipo == 'GASTO')}">selected</c:if>>
                        Gasto
                    </option>
                </select>
            </div>

            <%-- Campo: Monto --%>
            <div class="form-group">
                <label for="monto">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="12" y1="1" x2="12" y2="23"></line>
                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                    </svg>
                    Monto *
                </label>
                <input
                        type="number"
                        id="monto"
                        name="monto"
                        value="${plantilla != null ? plantilla.monto : param.monto}"
                        placeholder="0.00"
                        step="0.01"
                        min="0.01"
                        max="999999.99"
                        onblur="if(this.value) this.value = parseFloat(this.value).toFixed(2)"
                        required
                />
            </div>

            <%-- Campo: Categoría (Dinámico) --%>
            <div class="form-group">
                <label for="categoria">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="3" width="7" height="7"></rect>
                        <rect x="14" y="3" width="7" height="7"></rect>
                        <rect x="14" y="14" width="7" height="7"></rect>
                        <rect x="3" y="14" width="7" height="7"></rect>
                    </svg>
                    Categoría *
                </label>

                <%-- Dropdown para Ingresos --%>
                <select id="categoriaIngreso" name="categoria" style="display: none;" disabled>
                    <option value="">Seleccione una categoría</option>
                    <c:forEach var="categoria" items="<%= CategoriaIngreso.values() %>">
                        <option value="${categoria.name()}"
                                <c:choose>
                                    <c:when test="${plantilla != null && plantilla.categoria == categoria.name()}">selected</c:when>
                                    <c:when test="${plantilla == null && categoria.name() == param.categoria}">selected</c:when>
                                </c:choose>>
                                ${categoria.name()}
                        </option>
                    </c:forEach>
                </select>

                <%-- Dropdown para Gastos --%>
                <select id="categoriaGasto" style="display: none;" disabled>
                    <option value="">Seleccione una categoría</option>
                    <c:forEach var="categoria" items="<%= CategoriaGasto.values() %>">
                        <option value="${categoria.name()}"
                                <c:choose>
                                    <c:when test="${plantilla != null && plantilla.categoria == categoria.name()}">selected</c:when>
                                    <c:when test="${plantilla == null && categoria.name() == param.categoria}">selected</c:when>
                                </c:choose>>
                                ${categoria.name()}
                        </option>
                    </c:forEach>
                </select>

                <div id="categoriaPendiente" style="padding: 12px; background: rgba(255, 193, 7, 0.1); border: 1px solid #ffc107; border-radius: 4px; color: #ffc107; display: none;">
                    ⚠️ Primero selecciona el tipo de movimiento
                </div>
            </div>
        </div>

        <%-- Botones de Acción --%>
        <div class="form-actions" style="display: flex; gap: 12px; margin-top: 20px;">
            <button type="submit" class="btn btn-primary" id="btnGuardar">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
                <span>${textoBoton}</span>
            </button>
            <a href="${pageContext.request.contextPath}/movimientos" class="btn btn-secondary">
                Cancelar
            </a>
        </div>
    </form>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.querySelector('form.plantilla-form');
        const tipoSelect = document.getElementById('tipo');
        const categoriaIngresoSelect = document.getElementById('categoriaIngreso');
        const categoriaGastoSelect = document.getElementById('categoriaGasto');
        const categoriaPendiente = document.getElementById('categoriaPendiente');
        const montoInput = document.getElementById('monto');

        const btnGuardar = document.getElementById('btnGuardar');
        const esModoEdicion = ${esEdicion};

        if (btnGuardar) {
            btnGuardar.addEventListener('click', function(e) {
                if (esModoEdicion) {

                    const confirmar = confirm('¿Estás seguro de que deseas guardar los cambios en esta plantilla?');

                    if (!confirmar) {
                        e.preventDefault(); // Esto detiene el clic y evita que el formulario se envíe
                    }

                }
            });
        }

        function toggleCategorias() {
            const tipoValue = tipoSelect.value;

            if (tipoValue === 'INGRESO') {
                categoriaIngresoSelect.style.display = 'block';
                categoriaIngresoSelect.disabled = false;
                categoriaIngresoSelect.setAttribute('name', 'categoria');
                categoriaIngresoSelect.required = true;

                categoriaGastoSelect.style.display = 'none';
                categoriaGastoSelect.disabled = true;
                categoriaGastoSelect.removeAttribute('name');
                categoriaGastoSelect.required = false;

                categoriaPendiente.style.display = 'none';

            } else if (tipoValue === 'GASTO') {
                categoriaIngresoSelect.style.display = 'none';
                categoriaIngresoSelect.disabled = true;
                categoriaIngresoSelect.removeAttribute('name');
                categoriaIngresoSelect.required = false;

                categoriaGastoSelect.style.display = 'block';
                categoriaGastoSelect.disabled = false;
                categoriaGastoSelect.setAttribute('name', 'categoria');
                categoriaGastoSelect.required = true;

                categoriaPendiente.style.display = 'none';

            } else {
                // No hay tipo seleccionado
                categoriaIngresoSelect.style.display = 'none';
                categoriaIngresoSelect.disabled = true;
                categoriaIngresoSelect.removeAttribute('name');
                categoriaIngresoSelect.required = false;

                categoriaGastoSelect.style.display = 'none';
                categoriaGastoSelect.disabled = true;
                categoriaGastoSelect.removeAttribute('name');
                categoriaGastoSelect.required = false;

                categoriaPendiente.style.display = 'block';
            }
        }

        montoInput.addEventListener('blur', function() {
            const value = parseFloat(this.value);
            if (!isNaN(value)) {
                this.value = value.toFixed(2);
            }
        });

        montoInput.addEventListener('input', function() {
            const value = parseFloat(this.value);
            if (!isNaN(value) && value > 999999.99) {
                this.value = '999999.99';
            }
        });

        form.addEventListener('submit', function(e) {
            toggleCategorias();

            if (!tipoSelect.value) {
                e.preventDefault();
                alert('Por favor selecciona el tipo de movimiento');
                tipoSelect.focus();
                return false;
            }

            const monto = parseFloat(montoInput.value);
            if (isNaN(monto) || monto <= 0 || monto > 999999.99) {
                e.preventDefault();
                alert('El monto debe estar entre 0.01 y 999,999.99');
                montoInput.focus();
                return false;
            }

            const categoriaSelect = tipoSelect.value === 'INGRESO' ? categoriaIngresoSelect : categoriaGastoSelect;
            if (!categoriaSelect.value) {
                e.preventDefault();
                alert('Por favor selecciona una categoría');
                categoriaSelect.focus();
                return false;
            }
        });

        tipoSelect.addEventListener('change', toggleCategorias);

        toggleCategorias();
    });

    <c:if test="${esEdicion}">
    function confirmarEliminar() {
        if (confirm('¿Estás seguro de que deseas eliminar la plantilla "${plantilla.nombre}"?\n\AEsta acción no se puede deshacer.')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/plantillas/eliminar';

            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'id';
            input.value = '${plantilla.id}';

            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
    }
    </c:if>
</script>

<jsp:include page="/comun/VistaFooter.jsp" />