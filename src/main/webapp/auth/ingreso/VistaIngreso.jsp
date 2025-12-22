<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>EconoMe - Iniciar Sesión</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/auth.css">
  <style>
    .credentials-box {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 25px;
      color: white;
      box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
      border: 2px solid rgba(255, 255, 255, 0.2);
    }

    .credentials-box h3 {
      margin: 0 0 15px 0;
      font-size: 16px;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .credentials-box h3::before {
      content: "🔑";
      font-size: 20px;
    }

    .credential-item {
      background: rgba(255, 255, 255, 0.15);
      padding: 10px 15px;
      border-radius: 8px;
      margin-bottom: 10px;
      backdrop-filter: blur(10px);
    }

    .credential-item:last-child {
      margin-bottom: 0;
    }

    .credential-label {
      font-size: 12px;
      opacity: 0.9;
      margin-bottom: 4px;
      font-weight: 500;
    }

    .credential-value {
      font-family: 'Courier New', monospace;
      font-size: 14px;
      font-weight: 600;
      letter-spacing: 0.5px;
    }
  </style>
</head>
<body class = "login-page">
<!-- Logo y nombre FUERA del formulario -->
<div class="brand-header">
  <img src="${pageContext.request.contextPath}/resources/images/Logo.png" alt="EconoMe Logo" class="brand-logo">
  <h1 class="brand-name">Econo<span class="accent">Me</span></h1>
</div>

<!-- Contenedor del formulario -->
<div class="login-container">
  <h2 class="form-title">Iniciar Sesión</h2>

  <!-- Cuadro de credenciales de prueba -->
  <div class="credentials-box">
    <h3>Credenciales de Prueba</h3>
    <div class="credential-item">
      <div class="credential-label">Correo:</div>
      <div class="credential-value">juliosandobalin@gmail.com</div>
    </div>
    <div class="credential-item">
      <div class="credential-label">Contraseña:</div>
      <div class="credential-value">123456789!Aa</div>
    </div>
  </div>

  <% if (request.getAttribute("error") != null) { %>
  <div class="error-message show">
    <%= request.getAttribute("error") %>
  </div>
  <% } %>

  <form action="${pageContext.request.contextPath}/ingreso" method="post">
    <div class="form-group">
      <input
              type="text"
              id="identificadorUsuario"
              name="identificadorUsuario"
              placeholder="Usuario o correo electrónico"
              required
              autocomplete="username"
      >
    </div>

    <div class="form-group">
      <input
              type="password"
              id="contrasena"
              name="contrasena"
              placeholder="Contraseña"
              required
              autocomplete="contrasena"
      >
    </div>

    <button type="submit" class="btn-login">Iniciar Sesión</button>
  </form>

  <!-- Links debajo del botón -->
  <div class="links">
    <a href="${pageContext.request.contextPath}/registro">¿Eres nuevo? Regístrate</a>
  </div>
</div>
</body>
</html>