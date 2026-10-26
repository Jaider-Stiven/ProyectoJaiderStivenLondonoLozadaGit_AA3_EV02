# Sistema de Pedidos y Consulta con Consumo de API REST (JSP / Java)
## SENA - Tecnología en Análisis y Desarrollo de Software (ADSO)
### Evidencia: GA7-220501096-AA2-EV02 - Módulos de software codificados y probados

**Aprendiz:** Jaider Stiven Londoño Lozada  
**Repositorio GitHub:** [ProyectoJaiderStivenLondonoLozadaGit_AA2_EVO2](https://github.com/Jaider-Stiven/ProyectoJaiderStivenLondonoLozadaGit_AA2_EVO2)

---

## 📌 1. Descripción de la Solución

Este proyecto web implementa el módulo de **Gestión y Consulta de Pedidos de Comida** bajo la arquitectura **Modelo-Vista-Controlador (MVC)** utilizando tecnologías **Java Servlets**, **JavaServer Pages (JSP)** y **HTML5**.

Para dar cumplimiento estricto a la retroalimentación docente (*"jsp no consume ninguna api"*), se integró el **consumo de APIs REST externas en tiempo de ejecución desde Java**:

1. **Consumo de API REST mediante método HTTP `GET` (`buscar.jsp`):**
   - **Servicio consumido:** TheMealDB REST API (`https://www.themealdb.com/api/json/v1/1/search.php?s=...`).
   - **Propósito:** Búsqueda en tiempo real de alimentos, platos y recetas internacionales con sus categorías, país de procedencia, fotos e instrucciones.
   - **Implementación técnica:** Uso de la clase nativa `java.net.HttpURLConnection` en el backend JSP, lectura de flujos con `BufferedReader`, decodificación UTF-8 y parseo de respuestas JSON para renderizar dinámicamente una cuadrícula responsiva de tarjetas.

2. **Consumo de API REST mediante método HTTP `POST` (`resultado.jsp`):**
   - **Servicio consumido:** JSONPlaceholder REST API (`https://jsonplaceholder.typicode.com/posts`).
   - **Propósito:** Envío del pedido estructurado en formato JSON (`cliente`, `restaurante`, `comida`, `cantidad`, `fecha`), registrando la transacción en una API cloud que responde con código de estado `HTTP 201 Created` y un identificador único de seguimiento (`#ORD-API-101`).
   - **Implementación técnica:** Uso de `HttpURLConnection.setDoOutput(true)`, envío de payload JSON mediante `OutputStream` y lectura de respuesta HTTP.

---

## 📂 2. Estructura del Proyecto

```text
ProyectoJaiderStivenLondonoLozadaGit_AA2_EVO2/
│
├── index.html                   # Formulario principal de registro de pedidos
├── buscar.html                  # Formulario estilizado de búsqueda en la API
├── buscar.jsp                   # Consumo de API REST (GET) con TheMealDB y renderizado de platos
├── resultado.jsp                # Consumo de API REST (POST) para registrar pedido y mostrar comprobante
├── github.txt                   # Enlace al repositorio GitHub oficial
├── README.md                    # Documentación técnica completa del proyecto
│
├── src/
│   └── PedidoServlet.java       # Controlador Servlet para recepción y despacho de peticiones
│
└── WEB-INF/
    ├── web.xml                  # Descriptor de despliegue Jakarta EE / Servlet mapping
    └── classes/
        └── PedidoServlet.class  # Bytecode compilado del Servlet
```

---

## ⚙️ 3. Tecnologías y Librerías Utilizadas

- **Lenguaje:** Java SE 17+ / Java 26
- **Tecnologías Web:** JSP 3.0 / Jakarta Servlets 6.0 / HTML5 / CSS3 (Vanilla responsivo)
- **Servidor de Aplicaciones:** Apache Tomcat 10.1+
- **Protocolo de Comunicación:** HTTP/1.1 y REST (JSON)
- **Clases Java Clave:**
  - `java.net.HttpURLConnection`
  - `java.net.URL`
  - `java.net.URLEncoder`
  - `java.io.BufferedReader`
  - `java.io.OutputStream`
  - `java.util.regex.Pattern` / `java.util.regex.Matcher`

---

## 🚀 4. Guía de Ejecución y Pruebas

### Opción A: Despliegue en Apache Tomcat 10+
1. Copiar la carpeta del proyecto a la ruta `webapps` de Tomcat:
   ```text
   C:\Tomcat 10.1\webapps\ProyectoJaiderStivenLondonoLozadaGit_AA2_EVO2
   ```
2. Iniciar el servicio de Tomcat mediante el Administrador o ejecutando `startup.bat`.
3. Abrir el navegador e ingresar a:
   - Formulario de pedido: `http://localhost:8080/ProyectoJaiderStivenLondonoLozadaGit_AA2_EVO2/index.html`
   - Buscador API en JSP: `http://localhost:8080/ProyectoJaiderStivenLondonoLozadaGit_AA2_EVO2/buscar.jsp?restaurante=Pizza`
   - Comprobante con API POST: `http://localhost:8080/ProyectoJaiderStivenLondonoLozadaGit_AA2_EVO2/resultado.jsp`

### Opción B: Inspección de Archivos
- Todos los archivos `.jsp` y `.html` cuentan con validación visual y técnica del consumo de las APIs con visualización de estado HTTP (`200 OK` y `201 Created`).
