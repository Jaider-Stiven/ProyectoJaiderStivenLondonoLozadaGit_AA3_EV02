import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/PedidoServlet")
public class PedidoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String cliente = request.getParameter("cliente");
        String restaurante = request.getParameter("restaurante");
        String comida = request.getParameter("comida");
        String cantidad = request.getParameter("cantidad");

        request.setAttribute("cliente", cliente);
        request.setAttribute("restaurante", restaurante);
        request.setAttribute("comida", comida);
        request.setAttribute("cantidad", cantidad);

        // Reenvía a resultado.jsp donde se consume la API REST
        request.getRequestDispatcher("resultado.jsp").forward(request, response);
    }
}
