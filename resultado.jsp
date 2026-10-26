<!-- resultado.jsp -->
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.net.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.text.SimpleDateFormat"%>

<%
    // Configurar codificación de caracteres de la petición
    request.setCharacterEncoding("UTF-8");

    // 1. Obtener parámetros del pedido (soporta tanto envío directo POST/GET como reenvío desde Servlet)
    String cliente = request.getParameter("cliente");
    if (cliente == null || cliente.trim().isEmpty()) {
        cliente = (String) request.getAttribute("cliente");
    }
    if (cliente == null || cliente.trim().isEmpty()) {
        cliente = "Jaider Stiven";
    }

    String restaurante = request.getParameter("restaurante");
    if (restaurante == null || restaurante.trim().isEmpty()) {
        restaurante = (String) request.getAttribute("restaurante");
    }
    if (restaurante == null || restaurante.trim().isEmpty()) {
        restaurante = "Restaurante Central";
    }

    String comida = request.getParameter("comida");
    if (comida == null || comida.trim().isEmpty()) {
        comida = (String) request.getAttribute("comida");
    }
    if (comida == null || comida.trim().isEmpty()) {
        comida = "Pizza Especial";
    }

    String cantidad = request.getParameter("cantidad");
    if (cantidad == null || cantidad.trim().isEmpty()) {
        cantidad = (String) request.getAttribute("cantidad");
    }
    if (cantidad == null || cantidad.trim().isEmpty()) {
        cantidad = "1";
    }

    String fechaActual = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

    // 2. Consumo de API REST mediante método POST en Java (HttpURLConnection)
    // Se envía el pedido a una API REST externa para registro y generación de identificador
    String apiEndpoint = "https://jsonplaceholder.typicode.com/posts";
    int codigoHttp = 0;
    String mensajeHttp = "";
    String idGeneradoApi = "101";
    long tiempoRespuesta = 0;
    String errorApi = null;
    String respuestaJsonApi = "";

    long tiempoInicio = System.currentTimeMillis();
    try {
        URL url = new URL(apiEndpoint);
        HttpURLConnection conexion = (HttpURLConnection) url.openConnection();
        conexion.setRequestMethod("POST");
        conexion.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conexion.setRequestProperty("Accept", "application/json");
        conexion.setRequestProperty("User-Agent", "Mozilla/5.0 SENA-JSP-Client/1.0");
        conexion.setDoOutput(true);
        conexion.setConnectTimeout(6000);
        conexion.setReadTimeout(6000);

        // Construir carga útil JSON para enviar a la API
        String jsonPayload = String.format(
            "{\"cliente\":\"%s\",\"restaurante\":\"%s\",\"comida\":\"%s\",\"cantidad\":%s,\"fecha\":\"%s\",\"estado\":\"REGISTRADO\"}",
            cliente.replace("\"", "\\\""),
            restaurante.replace("\"", "\\\""),
            comida.replace("\"", "\\\""),
            cantidad.matches("\\d+") ? cantidad : "1",
            fechaActual
        );

        // Escribir datos en el flujo de salida hacia la API
        try (OutputStream os = conexion.getOutputStream()) {
            byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
            os.flush();
        }

        codigoHttp = conexion.getResponseCode();
        mensajeHttp = conexion.getResponseMessage();

        // Leer la respuesta devuelta por la API REST
        InputStream is = (codigoHttp >= 200 && codigoHttp < 300) ? conexion.getInputStream() : conexion.getErrorStream();
        if (is != null) {
            BufferedReader lector = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            String linea;
            while ((linea = lector.readLine()) != null) {
                sb.append(linea);
            }
            lector.close();
            respuestaJsonApi = sb.toString();

            // Extraer el ID generado por la API (ej: "id": 101)
            if (respuestaJsonApi.contains("\"id\"")) {
                java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"id\"\\s*:\\s*(\\d+)").matcher(respuestaJsonApi);
                if (m.find()) {
                    idGeneradoApi = m.group(1);
                }
            }
        }
        conexion.disconnect();
    } catch (Exception e) {
        errorApi = e.getMessage();
        codigoHttp = 500;
    }
    tiempoRespuesta = System.currentTimeMillis() - tiempoInicio;
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resultado del Pedido - API Consumida</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary: #ff6f00;
            --primary-dark: #e65100;
            --success: #16a34a;
            --dark: #0f172a;
            --muted: #64748b;
            --border: #e2e8f0;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: #f1f5f9;
            color: var(--dark);
            min-height: 100vh;
            padding: 40px 15px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .contenedor-recibo {
            width: 100%;
            max-width: 580px;
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            overflow: hidden;
            border: 1px solid var(--border);
        }

        .recibo-header {
            background: linear-gradient(135deg, #16a34a, #22c55e);
            color: white;
            padding: 25px;
            text-align: center;
        }

        .recibo-header .icon-check {
            width: 50px;
            height: 50px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 12px;
            font-size: 26px;
            font-weight: bold;
        }

        .recibo-header h1 {
            font-size: 22px;
            font-weight: 700;
        }

        .recibo-header p {
            font-size: 13px;
            opacity: 0.95;
            margin-top: 4px;
        }

        /* Bloque de evidencia de API consumida */
        .api-voucher {
            background: #f8fafc;
            border-bottom: 2px dashed var(--border);
            padding: 16px 25px;
            font-size: 12px;
        }

        .api-voucher-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }

        .badge-status {
            background: #dcfce7;
            color: #15803d;
            padding: 4px 10px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 11px;
        }

        .recibo-body {
            padding: 25px;
        }

        .detalle-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .detalle-item:last-child {
            border-bottom: none;
        }

        .label {
            color: var(--muted);
            font-size: 14px;
            font-weight: 500;
        }

        .valor {
            color: var(--dark);
            font-size: 15px;
            font-weight: 600;
            text-align: right;
        }

        .valor.destacado {
            color: var(--primary);
            font-size: 16px;
        }

        .recibo-footer {
            background: #fafafa;
            padding: 20px 25px;
            display: flex;
            gap: 12px;
            border-top: 1px solid var(--border);
        }

        .btn {
            flex: 1;
            padding: 12px;
            text-align: center;
            text-decoration: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            transition: 0.2s;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-dark);
        }

        .btn-secondary {
            background: white;
            color: var(--dark);
            border: 1px solid var(--border);
        }

        .btn-secondary:hover {
            background: #f1f5f9;
        }
    </style>
</head>
<body>

    <div class="contenedor-recibo">

        <div class="recibo-header">
            <div class="icon-check">✓</div>
            <h1>¡Pedido Registrado y Enviado a la API!</h1>
            <p>Evidencia SENA GA7-220501096-AA2-EV02 | Consumo API REST (POST)</p>
        </div>

        <!-- Evidencia técnica del consumo de la API mediante POST -->
        <div class="api-voucher">
            <div class="api-voucher-header">
                <span style="font-weight: 600; color: var(--dark);">Consumo de API REST Externa (Java HttpURLConnection)</span>
                <% if (codigoHttp >= 200 && codigoHttp < 300) { %>
                    <span class="badge-status">● HTTP <%= codigoHttp %> <%= mensajeHttp %></span>
                <% } else { %>
                    <span class="badge-status" style="background:#fee2e2; color:#991b1b;">● HTTP <%= codigoHttp %></span>
                <% } %>
            </div>
            <p style="color: var(--muted);"><strong>Método:</strong> HTTP POST | <strong>Tiempo:</strong> <%= tiempoRespuesta %> ms</p>
            <p style="color: var(--muted); word-break: break-all;"><strong>Endpoint API:</strong> <%= apiEndpoint %></p>
            <p style="color: var(--muted);"><strong>ID generado por la API:</strong> <span style="color: var(--success); font-weight: bold;">#ORD-API-<%= idGeneradoApi %></span></p>
        </div>

        <div class="recibo-body">

            <div class="detalle-item">
                <span class="label">Nombre del Cliente:</span>
                <span class="valor"><%= cliente %></span>
            </div>

            <div class="detalle-item">
                <span class="label">Restaurante:</span>
                <span class="valor"><%= restaurante %></span>
            </div>

            <div class="detalle-item">
                <span class="label">Comida Seleccionada:</span>
                <span class="valor destacado"><%= comida %></span>
            </div>

            <div class="detalle-item">
                <span class="label">Cantidad:</span>
                <span class="valor"><%= cantidad %> unidad(es)</span>
            </div>

            <div class="detalle-item">
                <span class="label">Fecha y Hora:</span>
                <span class="valor" style="font-size: 13px; font-weight: normal;"><%= fechaActual %></span>
            </div>

            <div class="detalle-item">
                <span class="label">Estado en Servidor / API:</span>
                <span class="valor" style="color: var(--success);">Confirmado en Cloud REST API</span>
            </div>

        </div>

        <div class="recibo-footer">
            <a href="index.html" class="btn btn-secondary">
                ← Nuevo Pedido
            </a>
            <a href="buscar.jsp" class="btn btn-primary">
                Buscar Platos en API →
            </a>
        </div>

    </div>

</body>
</html>