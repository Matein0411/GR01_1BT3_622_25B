<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%-- Definir que esta página generará HTML con codificación UTF-8 --%>
<%@ page isELIgnored="false" %> <%--  Habilita Expression Language (EL) para usar sintaxis ${variable} -->
<%-- Taglibs: Importa bibliotecas JSTL --%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %> <%-- c para control de flujo --%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %> <%-- fmt para formateo de numeros y fechas --%>

<%-- 1. header --%>
<jsp:include page="/comun/VistaHeader.jsp">
    <jsp:param name="title" value="Resumen Financiero"/>
</jsp:include>

<%-- 2. Variables Reutilizables (Introduce Explaining Variable) --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
<c:set var="tieneResumenes" value="${not empty ResumenesFinancieros}"/>
<c:set var="tieneResultados" value="${not empty Ingresos}"/>
<c:set var="tieneError" value="${not empty error}"/>


<jsp:include page="/comun/Mensajes.jsp" />
<%-- 4. Sección de Historial de Resúmenes --%>
<c:if test="${tieneResumenes}">
    <jsp:include page="componentes_resumen_financiero/EncabezadoSeccion.jsp">
        <jsp:param name="titulo" value="Historial de Resúmenes Financieros"/>
        <jsp:param name="textoBoton" value="Subir PDF"/>
        <jsp:param name="urlBoton" value="${contextPath}/resumen_financiero/componentes_resumen_financiero/FormularioSubirPDF.jsp"/>
    </jsp:include>

    <c:forEach var="resumen" items="${ResumenesFinancieros}">
        <div class="resumen-container">
            <h3 class="resumen-titulo">Resumen #${resumen.id}</h3>
            <p class="resumen-fecha">Fecha de Creación: ${resumen.fechaCreacionFormateada}</p>
            <p class="resumen-periodo">Período: ${resumen.fechaPeriodoAnterior} / ${resumen.fechaPeriodoActual}</p>
            <section style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1rem;">
                <%-- Tarjetas Reutilizables --%>
                <jsp:include page="componentes_resumen_financiero/TarjetaMetrica.jsp">
                    <jsp:param name="titulo" value="Ingresos"/>
                    <jsp:param name="valor" value="${resumen.ingresosTotales}"/>
                    <jsp:param name="color" value="#10b981"/>
                    <jsp:param name="descripcion" value="Depósitos y créditos"/>
                    <jsp:param name="icono" value="ingresos"/>
                </jsp:include>

                <jsp:include page="componentes_resumen_financiero/TarjetaMetrica.jsp">
                    <jsp:param name="titulo" value="Gastos"/>
                    <jsp:param name="valor" value="${resumen.gastosTotales}"/>
                    <jsp:param name="color" value="#ef4444"/>
                    <jsp:param name="descripcion" value="Cheques y débitos"/>
                    <jsp:param name="icono" value="gastos"/>
                </jsp:include>

                <jsp:include page="componentes_resumen_financiero/TarjetaAhorroNeto.jsp">
                    <jsp:param name="valor" value="${resumen.ahorroNeto}"/>
                </jsp:include>


            </section>
        </div>
        <br>
    </c:forEach>
</c:if>

<%-- 6. Sección de Resultados Individuales --%>
<c:if test="${tieneResultados}">
    <jsp:include page="componentes_resumen_financiero/EncabezadoSeccion.jsp">
        <jsp:param name="titulo" value="Resultados del Análisis"/>
        <jsp:param name="textoBoton" value="Subir Otro PDF"/>
        <jsp:param name="urlBoton" value="${contextPath}/resumen_financiero/componentes_resumen_financiero/FormularioSubirPDF.jsp"/>
    </jsp:include>

    <p class="resumen-fecha">Fecha de Creación: ${fechaCreacionFormateada}</p>
    <p class="resumen-periodo">Período: ${fechaPeriodoAnterior} / ${fechaPeriodoActual}</p>
    <br>
    <section class="grid">
        <jsp:include page="componentes_resumen_financiero/TarjetaMetrica.jsp">
            <jsp:param name="titulo" value="Ingresos Totales"/>
            <jsp:param name="valor" value="${Ingresos}"/>
            <jsp:param name="color" value="#10b981"/>
            <jsp:param name="descripcion" value="Depósitos y créditos del período"/>
            <jsp:param name="tamanoFuente" value="2rem"/>
            <jsp:param name="icono" value="ingresos"/>
        </jsp:include>

        <c:if test="${not empty Gastos}">
            <jsp:include page="componentes_resumen_financiero/TarjetaMetrica.jsp">
                <jsp:param name="titulo" value="Gastos Totales"/>
                <jsp:param name="valor" value="${Gastos}"/>
                <jsp:param name="color" value="#ef4444"/>
                <jsp:param name="descripcion" value="Cheques y débitos del período"/>
                <jsp:param name="tamanoFuente" value="2rem"/>
                <jsp:param name="icono" value="gastos"/>
            </jsp:include>
        </c:if>

        <c:if test="${not empty AhorroNeto}">
            <jsp:include page="componentes_resumen_financiero/TarjetaAhorroNeto.jsp">
                <jsp:param name="valor" value="${AhorroNeto}"/>
                <jsp:param name="tamanoFuente" value="2rem"/>
                <jsp:param name="descripcionPersonalizada" value="${AhorroNeto >= 0 ? 'Balance positivo del período' : 'Balance negativo del período'}"/>
            </jsp:include>
        </c:if>
    </section>
</c:if>

<%-- 7. Estado Vacío --%>
<c:if test="${empty Ingresos and empty error and empty ResumenesFinancieros}">
    <div class="empty-state">
        <div class="empty-state-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
                <line x1="16" y1="13" x2="8" y2="13"></line>
                <line x1="16" y1="17" x2="8" y2="17"></line>
                <polyline points="10 9 9 9 8 9"></polyline>
            </svg>
        </div>
        <h2>No existen resúmenes financieros registrados</h2>
        <p>Comienza registrando tu primer estado de cuenta bancario</p>

        <a href="${contextPath}/resumen_financiero/componentes_resumen_financiero/FormularioSubirPDF.jsp" class="btn btn-primary">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
            </svg>
            <span>Registrar Resumen</span>
        </a>
    </div>
</c:if>

<%-- 8. Scripts --%>
<script>
function updateFileName(input) {
    const fileName = input.files[0]?.name || 'Ningún archivo seleccionado';
    document.getElementById('file-name').textContent = fileName;
}

window.addEventListener('load', function() {
    const fileInput = document.getElementById('archivoPDF');
    if (fileInput) {
        fileInput.value = '';
        document.getElementById('file-name').textContent = 'Ningún archivo seleccionado';
    }
});
</script>

<%-- 9. Footer --%>
<jsp:include page="/comun/VistaFooter.jsp"/>