import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Clase de Lógica de Negocio y Validación para el Sistema FoodExpress.
 * SENA - ADSO - Evidencia GA7-220501096-AA3-EV02
 * Aprendiz: Jaider Stiven Londoño Lozada
 */
public class ValidadorPedido {

    // Expresión regular: solo letras, espacios y caracteres con tilde/diéresis en español
    private static final Pattern PATRON_TEXTO_SOLO_LETRAS = Pattern.compile("^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\\s]+$");
    
    // Expresión regular para caracteres especiales peligrosos (XSS / SQL Injection)
    private static final Pattern PATRON_CARACTERES_PELIGROSOS = Pattern.compile("[<>\"';`%\\\\=]");
    
    // Expresión regular para teléfono colombiano (10 dígitos numéricos)
    private static final Pattern PATRON_TELEFONO = Pattern.compile("^[0-9]{10}$");

    public static class ResultadoValidacion {
        private final boolean valido;
        private final List<String> errores;

        public ResultadoValidacion(boolean valido, List<String> errores) {
            this.valido = valido;
            this.errores = errores;
        }

        public boolean isValido() {
            return valido;
        }

        public List<String> getErrores() {
            return errores;
        }

        @Override
        public String toString() {
            if (valido) {
                return "[APROBADO] Todas las validaciones fueron superadas con éxito.";
            } else {
                return "[RECHAZADO] Errores encontrados (" + errores.size() + "):\n - " + String.join("\n - ", errores);
            }
        }
    }

    /**
     * Valida de manera integral todos los campos del pedido.
     */
    public static ResultadoValidacion validar(String cliente, String restaurante, String comida, 
                                              String cantidadStr, String fechaStr, String telefono, 
                                              String observaciones) {
        List<String> errores = new ArrayList<>();

        // 1. VALIDACIÓN DE TEXTOS Y LONGITUDES - CLIENTE
        if (cliente == null || cliente.trim().isEmpty()) {
            errores.add("El nombre del cliente es obligatorio.");
        } else {
            String c = cliente.trim();
            if (c.length() < 3 || c.length() > 60) {
                errores.add("El nombre del cliente debe tener entre 3 y 60 caracteres. Longitud recibida: " + c.length());
            }
            if (!PATRON_TEXTO_SOLO_LETRAS.matcher(c).matches()) {
                errores.add("El nombre del cliente solo debe contener letras y espacios (sin números ni símbolos especiales).");
            }
            if (PATRON_CARACTERES_PELIGROSOS.matcher(c).find()) {
                errores.add("El nombre del cliente contiene caracteres especiales potencialmente inseguros (<, >, \", ', ;, %, =, \\).");
            }
        }

        // 2. VALIDACIÓN DE TEXTOS Y LONGITUDES - RESTAURANTE
        if (restaurante == null || restaurante.trim().isEmpty()) {
            errores.add("El nombre del restaurante es obligatorio.");
        } else {
            String r = restaurante.trim();
            if (r.length() < 3 || r.length() > 50) {
                errores.add("El restaurante debe tener entre 3 y 50 caracteres.");
            }
            if (PATRON_CARACTERES_PELIGROSOS.matcher(r).find()) {
                errores.add("El campo restaurante contiene caracteres especiales no permitidos.");
            }
        }

        // 3. VALIDACIÓN DE TEXTOS Y LONGITUDES - COMIDA
        if (comida == null || comida.trim().isEmpty()) {
            errores.add("El plato o comida es obligatorio.");
        } else {
            String m = comida.trim();
            if (m.length() < 3 || m.length() > 50) {
                errores.add("El plato debe tener entre 3 y 50 caracteres.");
            }
            if (PATRON_CARACTERES_PELIGROSOS.matcher(m).find()) {
                errores.add("El campo de comida contiene caracteres especiales no permitidos.");
            }
        }

        // 4. VALIDACIÓN DE NÚMEROS Y RANGOS - CANTIDAD
        if (cantidadStr == null || cantidadStr.trim().isEmpty()) {
            errores.add("La cantidad es obligatoria.");
        } else {
            try {
                int cantidad = Integer.parseInt(cantidadStr.trim());
                if (cantidad < 1 || cantidad > 100) {
                    errores.add("La cantidad debe ser un número entero entre 1 y 100. Recibido: " + cantidad);
                }
            } catch (NumberFormatException e) {
                errores.add("La cantidad ingresada ('" + cantidadStr + "') no es un número entero válido.");
            }
        }

        // 5. VALIDACIÓN DE FECHAS - FORMATO Y LÓGICA TEMPORAL
        if (fechaStr == null || fechaStr.trim().isEmpty()) {
            errores.add("La fecha de entrega es obligatoria.");
        } else {
            try {
                LocalDate fecha = LocalDate.parse(fechaStr.trim());
                LocalDate hoy = LocalDate.now();
                if (fecha.isBefore(hoy)) {
                    errores.add("La fecha de entrega no puede ser una fecha pasada. Fecha ingresada: " + fecha + " (Hoy es: " + hoy + ").");
                }
                if (fecha.isAfter(hoy.plusDays(30))) {
                    errores.add("La fecha de entrega no puede superar 30 días en el futuro. Fecha ingresada: " + fecha);
                }
            } catch (DateTimeParseException e) {
                errores.add("El formato de fecha ('" + fechaStr + "') es inválido. Debe cumplir el estándar ISO YYYY-MM-DD.");
            }
        }

        // 6. VALIDACIÓN DE TELÉFONO (NUMÉRICO Y LONGITUD)
        if (telefono != null && !telefono.trim().isEmpty()) {
            String t = telefono.trim();
            if (!PATRON_TELEFONO.matcher(t).matches()) {
                errores.add("El teléfono de contacto debe contener exactamente 10 dígitos numéricos.");
            }
        }

        // 7. VALIDACIÓN DE OBSERVACIONES (LONGITUD Y CARACTERES ESPECIALES)
        if (observaciones != null && !observaciones.trim().isEmpty()) {
            String obs = observaciones.trim();
            if (obs.length() > 200) {
                errores.add("Las observaciones no pueden exceder 200 caracteres. Longitud actual: " + obs.length());
            }
            if (PATRON_CARACTERES_PELIGROSOS.matcher(obs).find()) {
                errores.add("Las observaciones contienen caracteres especiales no permitidos (<, >, \", ', ;, %, =, \\).");
            }
        }

        boolean esValido = errores.isEmpty();
        return new ResultadoValidacion(esValido, errores);
    }

    /**
     * Sanitiza una cadena escapando caracteres peligrosos para presentación segura.
     */
    public static String sanitizar(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;")
                    .replace("/", "&#x2F;");
    }
}
