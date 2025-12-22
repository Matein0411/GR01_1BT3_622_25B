<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ page import="com.sistema_financiero_personal.movimiento.modelos.CategoriaIngreso" %>
<%@ page import="com.sistema_financiero_personal.movimiento.modelos.CategoriaGasto" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/comun/VistaHeader.jsp">
    <jsp:param name="pageTitle" value="Gestor de Movimientos" />
</jsp:include>

<%-- Enlace al CSS Global (Formularios, Botones, Layout) --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
<%-- Enlace al CSS Específico de esta página (Sección Plantillas) --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/movimientos.css">

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/filters.css">


<div class="page-header">
    <h1>Gestor de Movimientos</h1>
</div>

<jsp:include page="/comun/Mensajes.jsp" />

<%-- Este contenedor ahora usa los estilos de style.css --%>
<div class="form-container">
    <form class="movimientos-form" method="post" action="${pageContext.request.contextPath}/movimientos">

        <div class="form-grid">
            <%-- Campo: Cuenta --%>
            <div class="form-group">
                <label for="cuentaId">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect>
                        <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path>
                    </svg>
                    Cuenta *
                </label>
                <select id="cuentaId" name="cuentaId" required>
                    <option value="">Seleccione una cuenta</option>
                    <c:forEach var="cuenta" items="${cuentas}">
                        <option value="${cuenta.id}"
                                data-saldo="${cuenta.monto}"
                                <c:if test="${cuenta.id == param.cuentaId}">selected</c:if>>
                                ${cuenta.nombre} (${cuenta.tipo}) - Saldo: $<fmt:formatNumber value="${cuenta.monto}" pattern="#,##0.00"/>
                        </option>
                    </c:forEach>
                </select>
                <c:if test="${empty cuentas}">
                    <small class="form-hint" style="color: #e74c3c;">
                        No hay cuentas disponibles.
                        <a href="${pageContext.request.contextPath}/cuentas/nuevo">Crear una cuenta</a>
                    </small>
                </c:if>
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
                    <option value="INGRESO" <c:if test="${param.tipo == 'INGRESO'}">selected</c:if>>Ingreso</option>
                    <option value="GASTO" <c:if test="${param.tipo == 'GASTO'}">selected</c:if>>Gasto</option>
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
                        value="${param.monto}"
                        placeholder="0.00"
                        step="0.01"
                        min="0.01"
                        onblur="if(this.value) this.value = parseFloat(this.value).toFixed(2)"
                        required
                />
                <small class="form-hint">El monto debe ser mayor a cero</small>
                <small id="saldoInsuficiente" class="form-hint" style="display: none; color: #e74c3c;">
                    ⚠️ El monto excede el saldo disponible
                </small>
            </div>

            <%-- Campo: Descripción --%>
            <div class="form-group">
                <label for="descripcion">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                        <line x1="16" y1="13" x2="8" y2="13"></line>
                        <line x1="16" y1="17" x2="8" y2="17"></line>
                        <polyline points="10 9 9 9 8 9"></polyline>
                    </svg>
                    Descripción *
                </label>
                <input
                        type="text"
                        id="descripcion"
                        name="descripcion"
                        value="${param.descripcion}"
                        placeholder="Ej: Pago de servicios básicos"
                        required
                        maxlength="200"
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
                <select id="categoriaIngreso" name="categoria" required style="display: none;" disabled>
                    <option value="">Seleccione una categoría</option>
                    <c:forEach var="categoria" items="<%= CategoriaIngreso.values() %>">
                        <option value="${categoria.name()}"
                                <c:if test="${categoria.name() == param.categoria}">selected</c:if>>
                                ${categoria.name()}
                        </option>
                    </c:forEach>
                </select>

                <%-- Dropdown para Gastos --%>
                <select id="categoriaGasto" style="display: none;" disabled required>
                    <option value="">Seleccione una categoría</option>
                    <c:forEach var="categoria" items="<%= CategoriaGasto.values() %>">
                        <option value="${categoria.name()}"
                                <c:if test="${categoria.name() == param.categoria}">selected</c:if>>
                                ${categoria.name()}
                        </option>
                    </c:forEach>
                </select>

                <%-- Advertencia si no se ha seleccionado tipo --%>
                <div id="categoriaPendiente" style="padding: 12px; background: rgba(255, 193, 7, 0.1); border: 1px solid #ffc107; border-radius: 4px; color: #ffc107; display: none;">
                    ⚠️ Primero selecciona el tipo de movimiento
                </div>
            </div>
        </div>

        <%-- Botones de Acción --%>
        <div class="form-actions" style="display: flex; gap: 12px;">

            <button type="submit" class="btn btn-primary" id="btnRegistrar">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
                <span>Registrar</span>
            </button>

            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary">
                Cancelar
            </a>
        </div>
    </form>
</div>

<%-- Sección de Plantillas (Usa clases de movimientos.css) --%>
<div class="plantillas-section">
    <div class="plantillas-header" onclick="togglePlantillas()">
        <div class="header-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
                <line x1="16" y1="13" x2="8" y2="13"></line>
                <line x1="16" y1="17" x2="8" y2="17"></line>
            </svg>
            <h3>Mis Plantillas</h3>
            <span class="badge">${not empty plantillas ? plantillas.size() : 0}</span>
        </div>
        <svg id="chevronIcon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="transition: transform 0.3s;">
            <polyline points="6 9 12 15 18 9"></polyline>
        </svg>
    </div>

    <div id="plantillasContent" style="display: none;">
        <div class="content-header">
            <div style="flex-grow: 1;">
                <p>Utiliza tus plantillas guardadas para registrar movimientos rápidamente</p>
            </div>

            <a href="${pageContext.request.contextPath}/plantillas/nuevo" class="btn btn-success" style="display: flex; align-items: center; gap: 8px; align-self: flex-start;">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="12" y1="5" x2="12" y2="19"></line>
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                Nueva Plantilla
            </a>
        </div>
        <div>
            <!-- FILTROS DE PLANTILLAS -->
            <div class="filters-container">
                <form method="get" action="${pageContext.request.contextPath}/plantillas/buscar" class="filters-form">
                    <!-- Filtro: Nombre -->
                    <div class="filter-group">
                        <label for="filtroNombre">Nombre</label>
                        <input
                                type="text"
                                id="filtroNombre"
                                name="nombre"
                                placeholder="Buscar por nombre..."
                                value="${filtroNombre}"
                        />
                    </div>

                    <!-- Filtro: Tipo -->
                    <div class="filter-group">
                        <label for="filtroTipo">Tipo</label>
                        <select id="filtroTipo" name="tipo">
                            <option value="TODOS" ${filtroTipo == 'TODOS' || empty filtroTipo ? 'selected' : ''}>Todos</option>
                            <option value="INGRESO" ${filtroTipo == 'INGRESO' ? 'selected' : ''}>Ingreso</option>
                            <option value="GASTO" ${filtroTipo == 'GASTO' ? 'selected' : ''}>Gasto</option>
                        </select>
                    </div>
                   
                    <!-- Botones -->
                    <div class="filter-actions">
                        <button class="btn btn-primary" type="submit">
                            Aplicar
                        </button>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/movimientos">
                            Limpiar
                        </a>
                    </div>
                </form>
            </div>

        </div>


        <c:choose>
            <c:when test="${not empty plantillas}">
                <div class="plantillas-grid">
                    <c:forEach var="plantilla" items="${plantillas}">
                        <div class="plantilla-card">
                            <span class="tipo-badge ${plantilla.tipo == 'INGRESO' ? 'ingreso' : 'gasto'}">
                                    ${plantilla.tipo}
                            </span>

                            <div class="card-info">
                                <h4>${plantilla.nombre}</h4>
                                <p>
                                    <strong>Categoría:</strong> ${plantilla.categoria}
                                </p>
                            </div>

                            <div class="card-monto">
                                <p class="${plantilla.tipo == 'INGRESO' ? 'ingreso' : 'gasto'}">
                                    $<fmt:formatNumber value="${plantilla.monto}" pattern="#,##0.00"/>
                                </p>
                            </div>

                            <div class="card-actions">
                                <button type="button" class="btn btn-primary"
                                        onclick="aplicarPlantilla(${plantilla.id})">
                                    Usar
                                </button>
                                <a href="${pageContext.request.contextPath}/plantillas/editar?id=${plantilla.id}" class="btn btn-edit">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                    </svg>
                                    Editar
                                </a>
                                <button type="button" class="btn btn-delete" onclick="confirmarEliminar(${plantilla.id}, '${plantilla.nombre}')">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <polyline points="3 6 5 6 21 6"></polyline>
                                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                                    </svg>
                                    Eliminar
                                </button>
                            </div>
                            <div style="text-align: center; margin-top: 8px;">
                                <a href="${pageContext.request.contextPath}/plantillas/duplicar?id=${plantilla.id}"
                                   class="btn-link-minimal">
                                    Duplicar
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <%-- Verificar si hay filtros aplicados --%>
                        <c:set var="hayFiltros" value="${not empty filtroNombre or (not empty filtroTipo and filtroTipo != 'TODOS')}" />

                        <div class="plantillas-empty-state">
                            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
                                <c:choose>
                                    <c:when test="${hayFiltros}">
                                        <%-- Icono de búsqueda sin resultados --%>
                                        <circle cx="11" cy="11" r="8"></circle>
                                        <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                        <line x1="8" y1="11" x2="14" y2="11"></line>
                                    </c:when>
                                    <c:otherwise>
                                        <%-- Icono de documento (actual) --%>
                                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                                        <polyline points="14 2 14 8 20 8"></polyline>
                                    </c:otherwise>
                                </c:choose>
                            </svg>

                            <c:choose>
                                <c:when test="${hayFiltros}">
                                    <p>No se encontraron plantillas que coincidan con tu búsqueda</p>
                                    <p class="subtext">Intenta ajustar los filtros o crear una nueva plantilla</p>
                                </c:when>
                                <c:otherwise>
                                    <p>No tienes plantillas guardadas</p>
                                    <p class="subtext">Crea tu primera plantilla para agilizar el registro de movimientos recurrentes</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
    /* Botón de enlace minimalista para "Duplicar" */
    .btn-link-minimal {
        display: inline-flex;
        align-items: center;
        padding: 6px 8px;
        font-size: 13px;
        color: #3498db;
        background: none;
        border: none;
        text-decoration: none;
        cursor: pointer;
        transition: color 0.2s ease;
    }

    .btn-link-minimal:hover {
        color: #2980b9;
        text-decoration: underline;
    }

    .btn-link-minimal:active {
        color: #1f6fa8;
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.querySelector('form.movimientos-form');
        const tipoSelect = document.getElementById('tipo');
        const categoriaIngresoSelect = document.getElementById('categoriaIngreso');
        const categoriaGastoSelect = document.getElementById('categoriaGasto');
        const categoriaPendiente = document.getElementById('categoriaPendiente');
        const montoInput = document.getElementById('monto');
        const cuentaSelect = document.getElementById('cuentaId');
        const saldoInsuficienteHint = document.getElementById('saldoInsuficiente');
        const btnRegistrar = document.getElementById('btnRegistrar');

        <c:if test="${movimientoPrecargado != null}">
        const movimiento = {
            descripcion: '${movimientoPrecargado.descripcion}',
            monto: ${movimientoPrecargado.monto},
            tipo: '${movimientoPrecargado.tipo}',
            categoria: '${movimientoPrecargado.categoria}',
            cuentaId: ${movimientoPrecargado.cuenta != null ? movimientoPrecargado.cuenta.id : 'null'}
        };

        // Precargar los campos
        document.getElementById('descripcion').value = movimiento.descripcion;
        document.getElementById('monto').value = movimiento.monto.toFixed(2);
        document.getElementById('tipo').value = movimiento.tipo;

        if (movimiento.cuentaId && movimiento.cuentaId !== 'null') {
            document.getElementById('cuentaId').value = movimiento.cuentaId;
        }

        // Trigger para mostrar las categorías correctas
        document.getElementById('tipo').dispatchEvent(new Event('change'));

        // Esperar y setear la categoría
        setTimeout(function() {
            if (movimiento.tipo === 'INGRESO') {
                document.getElementById('categoriaIngreso').value = movimiento.categoria;
            } else {
                document.getElementById('categoriaGasto').value = movimiento.categoria;
            }
        }, 100);

        // Feedback visual
        const descripcionInput = document.getElementById('descripcion');
        descripcionInput.style.background = '#d4edda';
        descripcionInput.style.borderColor = '#28a745';
        setTimeout(function() {
            descripcionInput.style.background = '';
            descripcionInput.style.borderColor = '';
        }, 2500);

        // Scroll al formulario
        document.querySelector('.movimientos-form').scrollIntoView({ behavior: 'smooth', block: 'start' });
        </c:if>

        // Toggle entre categorías de ingreso y gasto
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

        // Validar saldo suficiente para gastos
        function validarSaldo() {
            if (tipoSelect.value === 'GASTO' && cuentaSelect.value && montoInput.value) {
                const selectedOption = cuentaSelect.options[cuentaSelect.selectedIndex];
                const saldoDisponible = parseFloat(selectedOption.dataset.saldo || 0);
                const montoGasto = parseFloat(montoInput.value);

                if (!isNaN(montoGasto) && montoGasto > saldoDisponible) {
                    saldoInsuficienteHint.style.display = 'block';
                    btnRegistrar.disabled = true;
                    btnRegistrar.style.opacity = '0.5';
                    return false;
                } else {
                    saldoInsuficienteHint.style.display = 'none';
                    btnRegistrar.disabled = false;
                    btnRegistrar.style.opacity = '1';
                    return true;
                }
            } else {
                saldoInsuficienteHint.style.display = 'none';
                btnRegistrar.disabled = false;
                btnRegistrar.style.opacity = '1';
                return true;
            }
        }

        // Validación de monto personalizada
        montoInput.addEventListener('invalid', function() {
            if (montoInput.validity.valueMissing) {
                montoInput.setCustomValidity('');
            } else if (montoInput.validity.rangeUnderflow) {
                montoInput.setCustomValidity('Monto inválido. Debe ser mayor a cero');
            } else {
                montoInput.setCustomValidity('');
            }
        });

        montoInput.addEventListener('input', function() {
            montoInput.setCustomValidity('');
            validarSaldo();
        });

        // Formatear monto al perder el foco
        montoInput.addEventListener('blur', function() {
            const value = parseFloat(this.value);
            if (!isNaN(value)) {
                this.value = value.toFixed(2);
            }
        });

        // Validación antes de enviar el formulario
        form.addEventListener('submit', function(e) {
            toggleCategorias();

            if (!tipoSelect.value) {
                e.preventDefault();
                alert('Por favor selecciona el tipo de movimiento');
                tipoSelect.focus();
                return false;
            }

            const min = parseFloat(montoInput.min || '0.01');
            const val = parseFloat(montoInput.value);
            if (montoInput.value && (isNaN(val) || val < min)) {
                e.preventDefault();
                montoInput.setCustomValidity('Monto inválido. Debe ser mayor a cero');
                montoInput.reportValidity();
                return false;
            } else {
                montoInput.setCustomValidity('');
            }

            const categoriaSelect = tipoSelect.value === 'INGRESO' ? categoriaIngresoSelect : categoriaGastoSelect;
            if (!categoriaSelect.value) {
                e.preventDefault();
                alert('Por favor selecciona una categoría');
                categoriaSelect.focus();
                return false;
            }

            if (!validarSaldo()) {
                e.preventDefault();
                alert('El monto del gasto excede el saldo disponible en la cuenta seleccionada');
                return false;
            }
        });

        // Event listeners
        toggleCategorias();
        tipoSelect.addEventListener('change', function() {
            toggleCategorias();
            validarSaldo();
        });
        cuentaSelect.addEventListener('change', validarSaldo);
    });

    // Función para toggle de plantillas
    function togglePlantillas() {
        const content = document.getElementById('plantillasContent');
        const chevron = document.getElementById('chevronIcon');

        if (content.style.display === 'none') {
            content.style.display = 'block';
            chevron.style.transform = 'rotate(180deg)';
        } else {
            content.style.display = 'none';
            chevron.style.transform = 'rotate(0deg)';
        }
    }

    // Función para aplicar plantilla
    function aplicarPlantilla(id) {
        window.location.href = '${pageContext.request.contextPath}/plantillas/aplicar?id=' + id;
    }

    // Función para confirmar eliminación
    function confirmarEliminar(id, nombre) {
        if (confirm('¿Estás seguro de que deseas eliminar la plantilla "' + nombre + '"?\n\nEsta acción no se puede deshacer.')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/plantillas/eliminar';

            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'id';
            input.value = id;

            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const filtroTipo = document.getElementById('filtroTipo');
        const filtroCategoria = document.getElementById('filtroCategoria');
        const opciones = filtroCategoria.querySelectorAll('option');

        function actualizarCategoriasFiltro() {
            const tipo = filtroTipo.value;

            opciones.forEach(opt => {
                if (opt.value === 'TODAS') {
                    opt.hidden = false;
                    return;
                }

                // Si no hay tipo o es "TODOS", ocultar todo
                if (tipo === 'TODOS' || tipo === '') {
                    opt.hidden = true;
                } else {
                    opt.hidden = opt.dataset.tipo !== tipo;
                }
            });

            filtroCategoria.selectedIndex = 0; // Reinicia la selección
        }

        // Ejecutar al cargar y al cambiar el tipo
        actualizarCategoriasFiltro();
        filtroTipo.addEventListener('change', actualizarCategoriasFiltro);

        // Abrir sección SOLO si hay filtros aplicados
        const filtroNombre = '${filtroNombre}';
        const filtroTipoVal = '${filtroTipo}';
        const filtroCategoriaVal = '${filtroCategoria}';

        const hayFiltrosAplicados = filtroNombre ||
            (filtroTipoVal && filtroTipoVal !== 'TODOS' && filtroTipoVal !== '') ||
            (filtroCategoriaVal && filtroCategoriaVal !== 'TODAS' && filtroCategoriaVal !== '');

        // Solo abrir si hay filtros aplicados
        if (hayFiltrosAplicados) {
            const content = document.getElementById('plantillasContent');
            const chevron = document.getElementById('chevronIcon');
            content.style.display = 'block';
            chevron.style.transform = 'rotate(180deg)';
        }
    });
</script>

<jsp:include page="/comun/VistaFooter.jsp" />