<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.net.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.util.regex.*"%>
<%@page import="java.nio.charset.StandardCharsets"%>

<%!
    // Clase auxiliar para representar cada plato devuelto por la API
    public static class Plato {
        public String id;
        public String nombre;
        public String categoria;
        public String origen;
        public String imagen;
        public String instrucciones;

        public Plato(String id, String nombre, String categoria, String origen, String imagen, String instrucciones) {
            this.id = id;
            this.nombre = nombre;
            this.categoria = categoria;
            this.origen = origen;
            this.imagen = imagen;
            this.instrucciones = instrucciones;
        }
    }

    // Método para extraer campos de un objeto JSON sin requerir librerías externas
    private String extraerCampo(String bloque, String campo) {
        Pattern pattern = Pattern.compile("\"" + campo + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(bloque);
        if (matcher.find()) {
            return matcher.group(1).replace("\\\"", "\"").replace("\\/", "/");
        }
        return "";
    }
%>

<%
    // 1. Obtener el término de búsqueda enviado por el usuario
    String busqueda = request.getParameter("restaurante");
    if (busqueda == null || busqueda.trim().isEmpty()) {
        busqueda = request.getParameter("comida");
    }
    if (busqueda == null || busqueda.trim().isEmpty()) {
        busqueda = request.getParameter("q");
    }
    if (busqueda == null || busqueda.trim().isEmpty()) {
        busqueda = "pizza"; // Término por defecto para mostrar resultados inmediatamente
    }
    busqueda = busqueda.trim();

    // 2. Variables de diagnóstico del consumo de la API
    String apiEndpoint = "https://www.themealdb.com/api/json/v1/1/search.php?s=" + URLEncoder.encode(busqueda, "UTF-8");
    int codigoHttp = 0;
    String mensajeHttp = "";
    long tiempoRespuesta = 0;
    List<Plato> listaPlatos = new ArrayList<Plato>();
    String errorConexion = null;

    // 3. Consumo de la API REST externa mediante HttpURLConnection en Java
    long tiempoInicio = System.currentTimeMillis();
    try {
        URL url = new URL(apiEndpoint);
        HttpURLConnection conexion = (HttpURLConnection) url.openConnection();
        conexion.setRequestMethod("GET");
        conexion.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) SENA-JSP-Client/1.0");
        conexion.setRequestProperty("Accept", "application/json");
        conexion.setConnectTimeout(6000);
        conexion.setReadTimeout(6000);

        codigoHttp = conexion.getResponseCode();
        mensajeHttp = conexion.getResponseMessage();

        if (codigoHttp == 200) {
            BufferedReader lector = new BufferedReader(new InputStreamReader(conexion.getInputStream(), StandardCharsets.UTF_8));
            StringBuilder respuestaJson = new StringBuilder();
            String linea;
            while ((linea = lector.readLine()) != null) {
                respuestaJson.append(linea);
            }
            lector.close();

            String json = respuestaJson.toString();

            // Analizar la respuesta JSON si contiene "meals"
            if (json.contains("\"meals\":null") || json.contains("\"meals\": null")) {
                // No se encontraron platos con ese término
            } else {
                // Coincidir con cada objeto de plato dentro del arreglo meals
                Pattern objetoPattern = Pattern.compile("\\{(.*?)\\}");
                Matcher objetoMatcher = objetoPattern.matcher(json);
                while (objetoMatcher.find()) {
                    String bloque = objetoMatcher.group(1);
                    String id = extraerCampo(bloque, "idMeal");
                    String nombre = extraerCampo(bloque, "strMeal");
                    String categoria = extraerCampo(bloque, "strCategory");
                    String origen = extraerCampo(bloque, "strArea");
                    String imagen = extraerCampo(bloque, "strMealThumb");
                    String instrucciones = extraerCampo(bloque, "strInstructions");

                    if (nombre != null && !nombre.trim().isEmpty()) {
                        if (instrucciones.length() > 140) {
                            instrucciones = instrucciones.substring(0, 140) + "...";
                        }
                        listaPlatos.add(new Plato(id, nombre, categoria, origen, imagen, instrucciones));
                    }
                }
            }
        } else {
            errorConexion = "La API respondió con código de estado HTTP: " + codigoHttp;
        }
        conexion.disconnect();
    } catch (Exception e) {
        errorConexion = "Error al conectar con la API: " + e.getMessage();
    }
    tiempoRespuesta = System.currentTimeMillis() - tiempoInicio;
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consumo de API REST en JSP - Búsqueda de Comida</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary: #ff6f00;
            --primary-dark: #e65100;
            --secondary: #2e7d32;
            --dark: #1e293b;
            --light: #f8fafc;
            --card-bg: #ffffff;
            --border: #e2e8f0;
            --text-muted: #64748b;
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
            padding-bottom: 50px;
        }

        header {
            background: linear-gradient(135deg, #ff6f00, #ff8f00);
            color: white;
            padding: 30px 20px;
            box-shadow: 0 4px 15px rgba(255, 111, 0, 0.25);
        }

        .header-content {
            max-width: 1100px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        .header-title h1 {
            font-size: 26px;
            font-weight: 700;
        }

        .header-title p {
            font-size: 14px;
            opacity: 0.9;
        }

        .header-nav a {
            color: white;
            text-decoration: none;
            background: rgba(255, 255, 255, 0.2);
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            transition: 0.2s;
        }

        .header-nav a:hover {
            background: white;
            color: var(--primary-dark);
        }

        .contenedor {
            max-width: 1100px;
            margin: -20px auto 0;
            padding: 0 15px;
        }

        /* Tarjeta de información técnica del consumo de la API */
        .api-monitor {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
            margin-bottom: 25px;
            border-left: 5px solid var(--secondary);
        }

        .api-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 15px;
        }

        .api-badge {
            background: #dcfce7;
            color: #166534;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .api-badge.error {
            background: #fee2e2;
            color: #991b1b;
        }

        .api-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 12px;
            font-size: 13px;
            background: #f8fafc;
            padding: 12px;
            border-radius: 8px;
            border: 1px solid var(--border);
        }

        .api-details strong {
            color: var(--dark);
        }

        .api-details span {
            color: var(--text-muted);
            word-break: break-all;
        }

        /* Buscador */
        .search-box {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
            margin-bottom: 30px;
        }

        .search-form {
            display: flex;
            gap: 10px;
        }

        .search-form input {
            flex: 1;
            padding: 12px 16px;
            font-size: 15px;
            border: 2px solid var(--border);
            border-radius: 8px;
            outline: none;
            transition: 0.2s;
        }

        .search-form input:focus {
            border-color: var(--primary);
        }

        .search-form button {
            background: var(--primary);
            color: white;
            border: none;
            padding: 12px 24px;
            font-size: 15px;
            font-weight: 600;
            border-radius: 8px;
            cursor: pointer;
            transition: 0.2s;
        }

        .search-form button:hover {
            background: var(--primary-dark);
        }

        .quick-tags {
            margin-top: 12px;
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }

        .quick-tags span {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .quick-tags a {
            background: #f1f5f9;
            color: var(--dark);
            text-decoration: none;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            transition: 0.2s;
        }

        .quick-tags a:hover {
            background: var(--primary);
            color: white;
        }

        /* Grid de Resultados de la API */
        .results-header {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .results-header h2 {
            font-size: 20px;
            color: var(--dark);
        }

        .grid-platos {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
        }

        .card-plato {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            flex-direction: column;
            border: 1px solid var(--border);
        }

        .card-plato:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }

        .card-img-container {
            width: 100%;
            height: 180px;
            background: #e2e8f0;
            position: relative;
            overflow: hidden;
        }

        .card-img-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .card-body {
            padding: 16px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .card-badges {
            display: flex;
            gap: 6px;
            margin-bottom: 10px;
        }

        .badge-cat {
            background: #e0f2fe;
            color: #0369a1;
            font-size: 11px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 4px;
        }

        .badge-area {
            background: #fef3c7;
            color: #b45309;
            font-size: 11px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 4px;
        }

        .card-title {
            font-size: 17px;
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 8px;
        }

        .card-desc {
            font-size: 12px;
            color: var(--text-muted);
            line-height: 1.5;
            margin-bottom: 16px;
            flex: 1;
        }

        .card-footer {
            margin-top: auto;
        }

        .btn-order {
            display: block;
            width: 100%;
            text-align: center;
            background: var(--primary);
            color: white;
            text-decoration: none;
            padding: 10px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 14px;
            transition: 0.2s;
        }

        .btn-order:hover {
            background: var(--primary-dark);
        }

        .empty-state {
            background: white;
            padding: 40px;
            text-align: center;
            border-radius: 12px;
            color: var(--text-muted);
        }

        footer {
            text-align: center;
            margin-top: 40px;
            font-size: 13px;
            color: var(--text-muted);
        }
    </style>
</head>
<body>

    <header>
        <div class="header-content">
            <div class="header-title">
                <h1>Sistema FoodExpress - Consumo de API en JSP</h1>
                <p>Evidencia SENA GA7-220501096-AA2-EV02 | Aprendiz: Jaider Stiven Londoño Lozada</p>
            </div>
            <nav class="header-nav">
                <a href="index.html">← Formulario de Pedido</a>
                <a href="buscar.html">Buscador</a>
            </nav>
        </div>
    </header>

    <div class="contenedor">

        <!-- Panel de Diagnóstico y Evidencia del Consumo de la API -->
        <div class="api-monitor">
            <div class="api-header">
                <div>
                    <h3 style="font-size: 17px; color: var(--dark);">Detalle del Consumo de la API REST (Backend JSP)</h3>
                    <p style="font-size: 13px; color: var(--text-muted);">Petición HTTP realizada en tiempo de ejecución desde Java en este archivo JSP:</p>
                </div>
                <% if (codigoHttp == 200 && errorConexion == null) { %>
                    <div class="api-badge">
                        <span>●</span> API Conectada Exitosamente (HTTP <%= codigoHttp %> <%= mensajeHttp %>)
                    </div>
                <% } else { %>
                    <div class="api-badge error">
                        <span>●</span> <%= errorConexion != null ? errorConexion : "Error HTTP " + codigoHttp %>
                    </div>
                <% } %>
            </div>

            <div class="api-details">
                <div>
                    <strong>Servicio API:</strong><br>
                    <span>TheMealDB REST API (Alimentos y Recetas)</span>
                </div>
                <div>
                    <strong>Método HTTP:</strong><br>
                    <span style="font-weight: bold; color: var(--primary);">GET</span>
                </div>
                <div>
                    <strong>Endpoint Consultado:</strong><br>
                    <span><%= apiEndpoint %></span>
                </div>
                <div>
                    <strong>Tiempo de Respuesta:</strong><br>
                    <span><%= tiempoRespuesta %> ms</span>
                </div>
                <div>
                    <strong>Resultados Parseados:</strong><br>
                    <span><%= listaPlatos.size() %> platos encontrados</span>
                </div>
                <div>
                    <strong>Término Solicitado:</strong><br>
                    <span style="font-weight: 600; color: var(--secondary);"><%= busqueda %></span>
                </div>
            </div>
        </div>

        <!-- Formulario de Búsqueda -->
        <div class="search-box">
            <form action="buscar.jsp" method="get" class="search-form">
                <input type="text" name="restaurante" value="<%= busqueda %>" placeholder="Buscar comida, restaurante o ingrediente (Ej: Pizza, Chicken, Pasta, Burger)..." required>
                <button type="submit">Consultar API</button>
            </form>

            <div class="quick-tags">
                <span>Búsquedas rápidas en la API:</span>
                <a href="buscar.jsp?restaurante=Pizza">Pizza</a>
                <a href="buscar.jsp?restaurante=Burger">Burger</a>
                <a href="buscar.jsp?restaurante=Chicken">Chicken</a>
                <a href="buscar.jsp?restaurante=Pasta">Pasta</a>
                <a href="buscar.jsp?restaurante=Taco">Taco</a>
                <a href="buscar.jsp?restaurante=Salad">Salad</a>
                <a href="buscar.jsp?restaurante=Cake">Cake</a>
                <a href="buscar.jsp?restaurante=Beef">Beef</a>
            </div>
        </div>

        <!-- Resultados obtenidos de la API -->
        <div class="results-header">
            <h2>Resultados obtenidos desde la API para "<%= busqueda %>"</h2>
            <span style="font-size: 14px; color: var(--text-muted);"><%= listaPlatos.size() %> registros</span>
        </div>

        <% if (listaPlatos.isEmpty()) { %>
            <div class="empty-state">
                <h3>No se encontraron resultados para "<%= busqueda %>"</h3>
                <p style="margin-top: 8px;">Intenta con términos en inglés como <strong>Pizza, Burger, Pasta, Chicken, Beef, Fish, Soup</strong>.</p>
                <a href="buscar.jsp?restaurante=Pizza" style="display:inline-block; margin-top:15px; color: var(--primary); text-decoration: none; font-weight: 600;">Ver platos de Pizza sugeridos →</a>
            </div>
        <% } else { %>
            <div class="grid-platos">
                <% for (Plato plato : listaPlatos) { %>
                    <div class="card-plato">
                        <div class="card-img-container">
                            <img src="<%= plato.imagen %>" alt="<%= plato.nombre %>" loading="lazy">
                        </div>
                        <div class="card-body">
                            <div class="card-badges">
                                <% if (!plato.categoria.isEmpty()) { %>
                                    <span class="badge-cat"><%= plato.categoria %></span>
                                <% } %>
                                <% if (!plato.origen.isEmpty()) { %>
                                    <span class="badge-area"><%= plato.origen %></span>
                                <% } %>
                            </div>
                            <h3 class="card-title"><%= plato.nombre %></h3>
                            <p class="card-desc"><%= plato.instrucciones %></p>
                            <div class="card-footer">
                                <a href="index.html?comida=<%= URLEncoder.encode(plato.nombre, "UTF-8") %>&restaurante=<%= URLEncoder.encode(plato.origen + " Restaurant", "UTF-8") %>" class="btn-order">
                                    Pedir este plato
                                </a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>

        <footer>
            <p>Proyecto Jaider Stiven Londoño Lozada - Evidencia AA2_EV02 | Consumo de API REST con JSP / Java</p>
        </footer>

    </div>

</body>
</html>