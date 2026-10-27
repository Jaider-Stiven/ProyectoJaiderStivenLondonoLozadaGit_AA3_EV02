# FoodExpress - Sistema de Pedidos y Consulta con Consumo de API REST (JSP / Java)

## SENA - Tecnología en Análisis y Desarrollo de Software (ADSO)

### Evidencia: GA7-220501096-AA3-EV02 - Módulos de software stand-alone, web y móvil codificados y probados

**Aprendiz:** Jaider Stiven Londoño Lozada  
**Repositorio GitHub del proyecto:** [ProyectoJaiderStivenLondonoLozadaGit](https://github.com/Jaider-Stiven/ProyectoJaiderStivenLondonoLozadaGit_AA2_EVO2)

---

## 1. Descripción de la solución

Este proyecto implementa el módulo web **Gestión y Consulta de Pedidos de Comida** bajo la arquitectura **Modelo-Vista-Controlador (MVC)**, utilizando **Java Servlets**, **JavaServer Pages (JSP)** y **HTML5/CSS3**.

El módulo integra el **consumo de APIs REST externas en tiempo de ejecución desde Java**:

1. **Consumo de API REST mediante método HTTP `GET` (`buscar.jsp`):**
   - **Servicio consumido:** TheMealDB REST API (`https://www.themealdb.com/api/json/v1/1/search.php?s=...`).
   - **Propósito:** Búsqueda en tiempo real de alimentos, platos y recetas internacionales con sus categorías, país de procedencia, fotos e instrucciones.
   - **Implementación técnica:** Uso de la clase nativa `java.net.HttpURLConnection` en el backend JSP, lectura de flujos con `BufferedReader`, decodificación UTF-8 y parseo de respuestas JSON para renderizar dinámicamente una cuadrícula responsiva de tarjetas.

2. **Consumo de API REST mediante método HTTP `POST` (`resultado.jsp`):**
   - **Servicio consumido:** JSONPlaceholder REST API (`https://jsonplaceholder.typicode.com/posts`).
   - **Propósito:** Envío del pedido estructurado en formato JSON (`cliente`, `restaurante`, `comida`, `cantidad`, `fecha`), registrando la transacción en una API cloud que responde con código de estado `HTTP 201 Created` y un identificador único de seguimiento (`#ORD-...`).
   - **Implementación técnica:** Uso de `HttpURLConnection.setDoOutput(true)`, envío de payload JSON mediante `OutputStream` y lectura de respuesta HTTP.

3. **Validación en dos capas (cliente y servidor):**
   - **Frontend:** JavaScript puro con expresiones regulares, validación en tiempo real y mensajes contextuales.
   - **Backend:** Clase `ValidadorPedido.java`, con reglas de longitud, tipo de dato, rango numérico, fecha y sanitización de caracteres especiales.
   - **Pruebas automatizadas:** `ValidadorPedidoTest.java`, suite de 12 casos funcionales con ejecución por consola.

---

## 2. Estructura del proyecto

```text
ProyectoJaiderStivenLondonoLozadaGit_AA3_EV02/
│
├── index.html                   # Formulario principal de registro de pedidos y banco de pruebas
├── buscar.html                  # Formulario estilizado de búsqueda en la API
├── buscar.jsp                   # Consumo de API REST (GET) con TheMealDB y renderizado de platos
├── resultado.jsp                # Validación de servidor y consumo de API REST (POST)
├── github.txt                   # Enlace al repositorio GitHub oficial
├── README.md                    # Documentación técnica del proyecto
│
├── src/
│   ├── PedidoServlet.java       # Controlador Servlet para recepción y despacho de peticiones
│   ├── ValidadorPedido.java     # Lógica de negocio y validaciones del pedido
│   └── ValidadorPedidoTest.java # Suite de 12 pruebas automatizadas
│
└── WEB-INF/
    ├── web.xml                  # Descriptor de despliegue Jakarta EE / Servlet mapping
    └── classes/
        └── ...                  # Bytecode compilado del Servlet y del validador
```

---

## 3. Tecnologías y librerías utilizadas

- **Lenguaje:** Java SE 17+ / Java 26
- **Tecnologías Web:** JSP 3.0 / Jakarta Servlets 6.0 / HTML5 / CSS3 (Vanilla responsivo)
- **Servidor de Aplicaciones:** Apache Tomcat 10.1+
- **Protocolo de Comunicación:** HTTP/1.1 y REST (JSON)
- **Clases Java clave:**
  - `java.net.HttpURLConnection`
  - `java.net.URL`
  - `java.net.URLEncoder`
  - `java.io.BufferedReader`
  - `java.io.OutputStream`
  - `java.util.regex.Pattern` / `java.util.regex.Matcher`
  - `java.time.LocalDate`

---

## 4. Reglas de validación implementadas

| Campo | Regla de validación |
|---|---|
| Nombre del cliente | Obligatorio, solo letras y espacios, entre 3 y 60 caracteres. |
| Teléfono móvil | Obligatorio, exactamente 10 dígitos numéricos. |
| Restaurante | Obligatorio, entre 3 y 50 caracteres, sin caracteres peligrosos. |
| Plato o menú | Obligatorio, entre 3 y 50 caracteres, sin caracteres peligrosos. |
| Cantidad | Entero entre 1 y 100; rechaza negativos, cero, decimales y texto. |
| Fecha de entrega | Formato ISO `YYYY-MM-DD`, no anterior a hoy ni superior a 30 días. |
| Observaciones | Máximo 200 caracteres, sin `<`, `>`, `"`, `'`, `;`, `%`, `=`, `\`. |

La validación se ejecuta en el navegador (retroalimentación inmediata) y nuevamente en el servidor (integridad de datos).

---

## 5. Guía de ejecución y pruebas

### Opción A: Despliegue en Apache Tomcat 10+

1. Copiar la carpeta del proyecto a la ruta `webapps` de Tomcat:
   ```text
   C:\Tomcat 10.1\webapps\ProyectoJaiderStivenLondonoLozadaGit_AA3_EV02
   ```
2. Compilar las clases Java:
   ```text
   javac -encoding UTF-8 -cp "WEB-INF\lib\servlet-api.jar" -d "WEB-INF\classes" src\ValidadorPedido.java src\PedidoServlet.java
   ```
3. Iniciar Tomcat (`startup.bat`) y abrir en el navegador:
   - Formulario de pedido: `http://localhost:8080/ProyectoJaiderStivenLondonoLozadaGit_AA3_EV02/index.html`
   - Buscador API en JSP: `http://localhost:8080/ProyectoJaiderStivenLondonoLozadaGit_AA3_EV02/buscar.jsp?restaurante=Pizza`
   - Comprobante con API POST: `http://localhost:8080/ProyectoJaiderStivenLondonoLozadaGit_AA3_EV02/resultado.jsp`

### Opción B: Pruebas automatizadas por consola

```text
javac -encoding UTF-8 -d src src\ValidadorPedido.java src\ValidadorPedidoTest.java
java -cp src ValidadorPedidoTest
```

Resultado esperado: **12 pruebas ejecutadas, 12 aprobadas, 0 fallidas (100 %)**.

### Banco de pruebas rápidas del formulario

El formulario incluye parámetros de URL para reproducir cada caso durante la sustentación:

- `index.html?test=valido` - Pedido válido (camino feliz).
- `index.html?test=vacios` - Validación de campos obligatorios.
- `index.html?test=fecha` - Fecha anterior a hoy.
- `index.html?test=cantidad` - Cantidad negativa o fuera de rango.
- `index.html?test=longitud` - Longitud mínima de nombres.
- `index.html?test=xss` - Caracteres especiales e inyección XSS.

---

## 6. Control de versiones

El proyecto se administra con **Git** y se publica en **GitHub**. La rama de trabajo es `master`.

```text
git status
git add .
git commit -m "Pruebas y validaciones de la evidencia AA3-EV02"
git push origin master
```
