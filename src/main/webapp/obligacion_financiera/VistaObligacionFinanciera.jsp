<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<%-- 1. Incluimos el header --%>
<jsp:include page="/comun/VistaHeader.jsp">
    <jsp:param name="pageTitle" value="Deudas y Préstamos"/>
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/filters.css">


<%-- 2. Contenido específico --%>
<div class="page-header">
    <h1>Deudas y Préstamos</h1>
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/obligacion_financiera/nuevo">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        <span>Nueva Obligación</span>
    </a>
</div>

<%-- Filtros --%>
<div class="filters-container">
    <form method="get" action="deudas" class="filters-form">
        <input type="hidden" name="accion" value="listar">

        <div class="filter-group">
            <label for="nombrePersona">Persona</label>
            <input
                    type="text"
                    id="nombrePersona"
                    name="nombrePersona"
                    placeholder="Filtrar por persona"
                    value="${filtroNombre != null ? filtroNombre : ''}"
            />
        </div>

        <div class="filter-group">
            <label for="fechaInicio">Fecha inicio</label>
            <input
                    type="date"
                    id="fechaInicio"
                    name="fechaInicio"
                    value="${filtroFechaInicio != null ? filtroFechaInicio : ''}"
            />
        </div>

        <div class="filter-group">
            <label for="fechaFin">Fecha fin</label>
            <input
                    type="date"
                    id="fechaFin"
                    name="fechaFin"
                    value="${filtroFechaFin != null ? filtroFechaFin : ''}"
            />
        </div>

        <div class="filter-actions">
            <button class="btn btn-primary" type="submit">Aplicar</button>
            <a class="btn btn-secondary" href="deudas?accion=listar">Limpiar</a>
        </div>
    </form>
</div>

<jsp:include page="/comun/Mensajes.jsp" />

<%-- Estado vacío --%>
<c:if test="${empty deudas}">
    <div class="empty-state">
        <div class="empty-state-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"></circle>
                <path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"></path>
                <path d="M12 18V6"></path>
            </svg>
        </div>
        <h2>No hay obligaciones financieras</h2>
        <p>No tienes deudas ni préstamos registrados. ¡Crea tu primera obligación financiera!</p>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/obligacion_financiera/nuevo">Registrar obligación</a>
    </div>
</c:if>

<%-- Grid de obligaciones --%>
<c:if test="${not empty deudas}">
    <section class="grid">
        <c:forEach var="deuda" items="${deudas}">
            <article class="card">
                <div class="card-header">
                    <div class="card-icon ${deuda.getClass().simpleName == 'Deuda' ? 'icon-deuda' : 'icon-prestamo'}">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"></circle>
                            <path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"></path>
                            <path d="M12 18V6"></path>
                        </svg>
                    </div>
                    <h3 class="card-title"><c:out value="${deuda.nombrePersona}"/></h3>
                </div>

                <div class="card-body">
                    <p><strong>Tipo:</strong> ${deuda.getClass().simpleName}</p>
                    <p><strong>Estado:</strong> ${deuda.estado}</p>

                    <div class="amounts-section">
                        <p><strong>Monto Total:</strong> <fmt:formatNumber value="${deuda.montoTotal}" type="currency" currencySymbol="$" /></p>
                        <p><strong>Monto Pagado:</strong> <fmt:formatNumber value="${deuda.montoPagado}" type="currency" currencySymbol="$" /></p>
                        <p class="amount"><strong>Saldo Pendiente:</strong> <span class="balance"><fmt:formatNumber value="${deuda.calcularSaldoPendiente()}" type="currency" currencySymbol="$" /></span></p>
                        <p><strong>Fecha de Pago:</strong> ${deuda.fechaPago}</p>
                    </div>

                        <%-- Progreso del pago --%>
                    <c:set var="porcentajePagado" value="${(deuda.montoPagado / deuda.montoTotal) * 100}" />
                    <div class="progress-container">
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: ${porcentajePagado}%"></div>
                        </div>
                        <span class="progress-text">
                            <fmt:formatNumber value="${porcentajePagado}" pattern="#0" />% pagado
                        </span>
                    </div>
                </div>

                <div class="card-footer">
                    <form method="post" action="deudas" class="abono-form">
                        <input type="hidden" name="accion" value="abonar">
                        <input type="hidden" name="idDeuda" value="${deuda.id}">

                        <div class="abono-inputs">
                            <select name="idCartera" required class="select-cuenta">
                                <option value="">Seleccionar cuenta</option>
                                <c:forEach var="cuenta" items="${cuentas}">
                                    <option value="${cuenta.id}">
                                            ${cuenta.nombre} - <fmt:formatNumber value="${cuenta.monto}" type="currency" currencySymbol="$" />
                                    </option>
                                </c:forEach>
                            </select>

                            <input
                                    type="number"
                                    name="monto"
                                    min="0.01"
                                    max="${deuda.calcularSaldoPendiente()}"
                                    step="0.01"
                                    placeholder="Monto a abonar"
                                    required
                                    class="input-monto"
                            />
                        </div>

                        <button class="btn btn-primary btn-full" type="submit">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="20 6 9 17 4 12"></polyline>
                            </svg>
                            Abonar
                        </button>
                    </form>
                </div>
            </article>
        </c:forEach>
    </section>
</c:if>

<%-- 3. Incluimos el footer --%>
<jsp:include page="/comun/VistaFooter.jsp" />