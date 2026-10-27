import java.time.LocalDate;

/**
 * Suite de Pruebas Automatizadas para Validación de Entradas.
 * Evidencia GA7-220501096-AA3-EV02 - Módulos de software codificados y probados.
 * Aprendiz: Jaider Stiven Londoño Lozada
 */
public class ValidadorPedidoTest {

    private static int pruebasEjecutadas = 0;
    private static int pruebasExitosas = 0;
    private static int pruebasFallidas = 0;

    public static void main(String[] args) {
        System.out.println("================================================================================");
        System.out.println("   SENA - TECNOLOGÍA EN ANÁLISIS Y DESARROLLO DE SOFTWARE (ADSO)");
        System.out.println("   EVIDENCIA: GA7-220501096-AA3-EV02 - PRUEBAS DE MÓDULOS CODIFICADOS");
        System.out.println("   APRENDIZ: JAIDER STIVEN LONDOÑO LOZADA");
        System.out.println("   BATERÍA DE PRUEBAS DE VALIDACIÓN FUNCIONAL: FECHAS, NÚMEROS, TEXTOS, ETC.");
        System.out.println("================================================================================\n");

        LocalDate hoy = LocalDate.now();
        String fechaHoy = hoy.toString();
        String fechaPasada = hoy.minusDays(5).toString();
        String fechaLejana = hoy.plusDays(45).toString();

        // CP-01: Pedido totalmente válido (Camino feliz)
        ejecutarPrueba("CP-01", "Validación de pedido con datos completos y válidos", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Jaider Stiven Londoño", "Pizzería Gourmet", "Spicy Arrabiata Penne", 
                "2", fechaHoy, "3104567890", "Entregar caliente por favor"
            );
            return res.isValido();
        });

        // CP-02: Validación de Campos Obligatorios (Nulos / Vacíos)
        ejecutarPrueba("CP-02", "Validación de campos obligatorios vacíos", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "", "", "", "", "", "", ""
            );
            return !res.isValido() && res.getErrores().size() >= 5;
        });

        // CP-03: Validación de Fechas - Rechazo de Fechas Pasadas
        ejecutarPrueba("CP-03", "Validación de fechas: Rechazo de fecha anterior a hoy (" + fechaPasada + ")", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Jaider Stiven", "Restaurante Central", "Pasta Carbonara", 
                "1", fechaPasada, "3001234567", ""
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("fecha pasada"));
        });

        // CP-04: Validación de Fechas - Rechazo de Formato Inválido
        ejecutarPrueba("CP-04", "Validación de fechas: Formato no ISO (31/12/2026)", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Jaider Stiven", "Restaurante Central", "Pasta Carbonara", 
                "1", "31/12/2026", "3001234567", ""
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("inválido"));
        });

        // CP-05: Validación de Números - Cantidad negativa o cero
        ejecutarPrueba("CP-05", "Validación de números: Rechazo de cantidad negativa o cero (-3)", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Jaider Stiven", "Restaurante Central", "Pizza Jamon", 
                "-3", fechaHoy, "3001234567", ""
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("entre 1 y 100"));
        });

        // CP-06: Validación de Números - Cantidad que excede el rango máximo (> 100)
        ejecutarPrueba("CP-06", "Validación de números: Cantidad fuera de límite superior (250)", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Jaider Stiven", "Restaurante Central", "Pizza Jamon", 
                "250", fechaHoy, "3001234567", ""
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("entre 1 y 100"));
        });

        // CP-07: Validación de Números - Caracteres alfabéticos en campo cantidad
        ejecutarPrueba("CP-07", "Validación de números: Tipo de dato no numérico ('dos')", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Jaider Stiven", "Restaurante Central", "Pizza Jamon", 
                "dos", fechaHoy, "3001234567", ""
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("no es un número entero válido"));
        });

        // CP-08: Validación de Textos - Nombre de cliente con números o caracteres inválidos
        ejecutarPrueba("CP-08", "Validación de textos: Nombre de cliente con números ('Jaider123')", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Jaider123", "Restaurante Central", "Hamburguesa", 
                "2", fechaHoy, "3001234567", ""
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("solo debe contener letras"));
        });

        // CP-09: Validación de Longitudes - Longitud insuficiente en cliente (< 3 caracteres)
        ejecutarPrueba("CP-09", "Validación de longitudes: Nombre menor a 3 caracteres ('Al')", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Al", "Restaurante Central", "Hamburguesa", 
                "2", fechaHoy, "3001234567", ""
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("entre 3 y 60"));
        });

        // CP-10: Validación de Caracteres Especiales - Inyección XSS o código malicioso
        ejecutarPrueba("CP-10", "Validación de caracteres especiales: Prevención XSS (<script>alert(1)</script>)", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "<script>alert(1)</script>", "Restaurante Central", "Hamburguesa", 
                "2", fechaHoy, "3001234567", "<script>hack</script>"
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("caracteres especiales"));
        });

        // CP-11: Validación de Teléfono - Longitud distinta a 10 dígitos
        ejecutarPrueba("CP-11", "Validación numérica de teléfono: Menos de 10 dígitos ('310123')", () -> {
            ValidadorPedido.ResultadoValidacion res = ValidadorPedido.validar(
                "Jaider Stiven", "Restaurante Central", "Hamburguesa", 
                "2", fechaHoy, "310123", ""
            );
            return !res.isValido() && res.getErrores().stream().anyMatch(e -> e.contains("10 dígitos"));
        });

        // CP-12: Validación de Sanitización XSS
        ejecutarPrueba("CP-12", "Validación de función sanitizadora HTML (Prevención de inyección)", () -> {
            String sucio = "<script>alert('test')</script>";
            String limpio = ValidadorPedido.sanitizar(sucio);
            return limpio.equals("&lt;script&gt;alert(&#x27;test&#x27;)&lt;&#x2F;script&gt;");
        });

        System.out.println("--------------------------------------------------------------------------------");
        System.out.println("RESUMEN DE PRUEBAS EJECUTADAS:");
        System.out.println("Total de pruebas: " + pruebasEjecutadas);
        System.out.println("Pruebas Aprobadas (Pass): " + pruebasExitosas);
        System.out.println("Pruebas Fallidas (Fail): " + pruebasFallidas);
        System.out.println("Efectividad del conjunto de pruebas: " + ((pruebasExitosas * 100) / pruebasEjecutadas) + "%");
        System.out.println("================================================================================");
    }

    private static void ejecutarPrueba(String id, String descripcion, CasoDePrueba caso) {
        pruebasEjecutadas++;
        try {
            boolean resultado = caso.ejecutar();
            if (resultado) {
                pruebasExitosas++;
                System.out.printf("[%s] [APROBADO] %s%n", id, descripcion);
            } else {
                pruebasFallidas++;
                System.err.printf("[%s] [FALLIDO]  %s%n", id, descripcion);
            }
        } catch (Exception e) {
            pruebasFallidas++;
            System.err.printf("[%s] [ERROR]    %s -> Excepción: %s%n", id, descripcion, e.getMessage());
        }
    }

    @FunctionalInterface
    interface CasoDePrueba {
        boolean ejecutar() throws Exception;
    }
}
