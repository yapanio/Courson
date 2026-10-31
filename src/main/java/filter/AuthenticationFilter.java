package filter;

import dto.UserDto;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;
import util.SessionUtil;

@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/*"})
public class AuthenticationFilter implements Filter {
    private Set<String> publicPaths = new HashSet<>();

    @Override
    public void init(FilterConfig config) throws ServletException {
        publicPaths.add("/auth");
        publicPaths.add("/verify");
        publicPaths.add("/home");
        publicPaths.add("/courses/catalog");
        publicPaths.add("/courses/detail");
        publicPaths.add("/assets");
        publicPaths.add("/css");
        publicPaths.add("/js");
        publicPaths.add("/images");
        publicPaths.add("/uploads");
        publicPaths.add("/index.html");
        publicPaths.add("/demo.html");
        publicPaths.add("/favicon.ico");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();
        String pathInfo = req.getPathInfo();
        String fullPath = path + (pathInfo != null ? pathInfo : "");

        if (isPublicPath(fullPath)) {
            chain.doFilter(request, response);
            return;
        }

        UserDto currentUser = SessionUtil.getCurrentUser(req);
        if (currentUser != null) {
            chain.doFilter(request, response);
        } else {
            redirectToLogin(req, resp);
        }
    }

    @Override
    public void destroy() {
    }

    private boolean isPublicPath(String path) {
        if (path == null || path.isEmpty() || path.equals("/")) {
            return true;
        }
        for (String publicPrefix : publicPaths) {
            if (path.startsWith(publicPrefix)) {
                return true;
            }
        }
        return false;
    }

    private void redirectToLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String target = req.getContextPath() + "/auth/login";
        resp.sendRedirect(target);
    }
}
