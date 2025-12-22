package com.sistema_financiero_personal.plantillas.servicios;

import com.sistema_financiero_personal.movimiento.modelos.*;
import com.sistema_financiero_personal.plantillas.daos.DAOPlantilla;
import com.sistema_financiero_personal.plantillas.modelos.Plantilla;
import com.sistema_financiero_personal.usuario.daos.DAOUsuario;
import com.sistema_financiero_personal.usuario.modelos.Usuario;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Set;

public class ServicioPlantilla {

    private final DAOPlantilla dao;
    private DAOUsuario daoUsuario;
    private List<Plantilla> plantillas = new ArrayList<>();
    private static final Set<String> TIPOS_VALIDOS = Set.of("GASTO", "INGRESO");


    public ServicioPlantilla() {
        this.dao = new DAOPlantilla();
        this.daoUsuario = new DAOUsuario();
    }

    public ServicioPlantilla(DAOPlantilla dao, DAOUsuario daoUsuario) {
        this.dao = dao;
        this.daoUsuario = daoUsuario;
    }
/*
utilice Extract Method para mover las validaciones de crearPlantilla a un nuevo método llamado validarPlantilla.
*   Antes :
* public void crearPlantilla(Plantilla plantilla, Long usuario_id) {
    if (plantilla == null) {
        throw new IllegalArgumentException("Plantilla no puede ser nula");
    }

    boolean estaVacio = plantilla.getNombre() == null || plantilla.getNombre().isEmpty();
    boolean estaEnBlanco = plantilla.getNombre() != null && plantilla.getNombre().isBlank();
    if(estaVacio || estaEnBlanco){
        throw new IllegalArgumentException("El nombre no puede estar vacío");
    }

    validarMonto(plantilla.getMonto());
    String tipo = plantilla.getTipo();
    validarTipo(tipo);
    Object categoriaEnum = plantilla.getCategoriaEnum();
    String categoriaStr = (categoriaEnum != null) ? categoriaEnum.toString() : null;
    validarCategoria(tipo, categoriaStr);

    Usuario usuario = daoUsuario.buscarPorId(usuario_id);
    plantilla.setUsuario(usuario);
    plantilla.setFechaCreacion(LocalDateTime.now());
    dao.crear(plantilla);
}
Después :
* */
    public void crearPlantilla(Plantilla plantilla, Long usuarioId) {
        validarPlantilla(plantilla);

        Usuario usuario = daoUsuario.buscarPorId(usuarioId);
        plantilla.setUsuario(usuario);
        plantilla.setFechaCreacion(LocalDateTime.now());
        if (dao.existePlantillaPorNombre(plantilla.getNombre().trim(), usuarioId)) {
            throw new IllegalStateException("Ya existe una plantilla con el mismo nombre");
        }
        dao.crear(plantilla);
    }

    private void validarPlantilla(Plantilla plantilla) {
        if (plantilla == null) {
            throw new IllegalArgumentException("Plantilla no puede ser nula");
        }

        validarCampoNoVacio(plantilla.getNombre(), "El nombre");

        validarMonto(plantilla.getMonto());
        validarTipo(plantilla.getTipo());

        Object categoriaEnum = plantilla.getCategoriaEnum();
        String categoriaStr = (categoriaEnum != null) ? categoriaEnum.toString() : null;
        validarCategoria(plantilla.getTipo(), categoriaStr);
    }

//
    public void validarMonto(double monto) {
        if (Double.isNaN(monto) || monto <= 0.0 || monto > 999_999.99) {
            throw new IllegalArgumentException("Monto no válido");
        }
        redondearMonto(monto);
    }


    public void validarTipo(String tipo) {

        validarCampoNoVacio(tipo, "El tipo");

        if (!TIPOS_VALIDOS.contains(tipo)) {
            throw new IllegalArgumentException("Tipo inválido");
        }
    }

    public void validarCategoria(String tipo, String categoria) {

        validarCampoNoVacio(categoria, "La categoría");

        try {
            if ("GASTO".equalsIgnoreCase(tipo)) {
                CategoriaGasto.valueOf(categoria.toUpperCase());
            } else if ("INGRESO".equalsIgnoreCase(tipo)) {
                CategoriaIngreso.valueOf(categoria.toUpperCase());
            } else {
                throw new IllegalArgumentException("Tipo inválido para validación de categoría");
            }
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Categoría inválida");
        }
    }

    private void validarCampoNoVacio(String valor, String mensajeCampo) {
        if (valor == null || valor.isBlank()) {
            throw new IllegalArgumentException(mensajeCampo + " no puede estar vacío o en blanco");
        }
    }

    public void eliminarPlantilla(Long plantilla_Id) {
        dao.borrar(plantilla_Id);
    }

    public Movimiento aplicarPlantilla(Plantilla plantilla) {
        if (plantilla == null) {
            throw new IllegalArgumentException("La plantilla no puede ser nula");
        }

        if (!plantilla.isActivo()) {
            throw new IllegalStateException("La plantilla debe estar activa");
        }

        String descripcion = plantilla.getNombre();

        Movimiento movimiento;

        if ("INGRESO".equals(plantilla.getTipo())) {
            movimiento = new Ingreso(
                    plantilla.getMonto(),
                    LocalDateTime.now(),
                    descripcion,
                    (CategoriaIngreso) plantilla.getCategoriaEnum()
            );
        } else if ("GASTO".equals(plantilla.getTipo())) {
            movimiento = new Gasto(
                    plantilla.getMonto(),
                    LocalDateTime.now(),
                    descripcion,
                    (CategoriaGasto) plantilla.getCategoriaEnum()
            );
        } else {
            throw new IllegalArgumentException("Tipo de plantilla inválido: " + plantilla.getTipo());
        }

        movimiento.setCuenta(plantilla.getCuenta());
        return movimiento;
    }

    public Plantilla duplicarPlantilla(Plantilla original) {
        if (original == null) {
            throw new IllegalArgumentException("Plantilla original requerida");
        }

        Plantilla copia = new Plantilla();

        Long usuarioId = (original.getUsuario() != null) ? original.getUsuario().getId() : null;
        copia.setNombre(generarNombreUnico(original.getNombre(), usuarioId));

        copia.setMonto(original.getMonto());
        copia.setTipo(original.getTipo());
        copia.setCategoria(original.getCategoria());
        copia.setCuenta(original.getCuenta());
        copia.setActivo(true);
        copia.setFechaCreacion(LocalDateTime.now());

        return copia;
    }

    private String generarNombreUnico(String nombreOriginal, Long usuarioId) {
        String nombreBase = extraerNombreBase(nombreOriginal);

        // Combinar lista en memoria (tests) con BD (producción)
        List<Plantilla> plantillasExistentes = new ArrayList<>(plantillas);

        if (usuarioId != null) {
            try {
                List<Plantilla> plantillasBD = listarPlantillasPorUsuario(usuarioId);
                if (plantillasBD != null) {
                    plantillasExistentes.addAll(plantillasBD);
                }
            } catch (Exception e) {
                // Continuar solo con la lista en memoria
            }
        }

        int maxNumero = 0;

        for (Plantilla p : plantillasExistentes) {
            String nombreActual = p.getNombre();

            if (nombreActual.equals(nombreBase)) {
                maxNumero = Math.max(maxNumero, 1);
            } else if (nombreActual.startsWith(nombreBase + " (")) {
                try {
                    String numeroStr = nombreActual.substring(
                            nombreBase.length() + 2,
                            nombreActual.length() - 1
                    );
                    int numero = Integer.parseInt(numeroStr);
                    maxNumero = Math.max(maxNumero, numero);
                } catch (Exception e) {
                    // Ignorar errores de parsing
                }
            }
        }

        return maxNumero == 0 ? nombreBase : nombreBase + " (" + (maxNumero) + ")";
    }

    private String extraerNombreBase(String nombreCompleto) {
        if (nombreCompleto.matches(".+ \\(\\d+\\)")) {
            return nombreCompleto.substring(0, nombreCompleto.lastIndexOf(" ("));
        }
        return nombreCompleto;
    }

    public double redondearMonto(double monto) {
        return Math.round(monto * 100.0) / 100.0;
    }
    public void actualizarPlantilla(Plantilla plantilla){
        dao.actualizar(plantilla);
    }

    public Plantilla buscarPorId(Long id) {
        return dao.buscarPorId(id);
    }

    public List<Plantilla> listarPlantillasPorUsuario(Long usuarioId) {
        return dao.buscarPorCampo("usuario.id", usuarioId);
    }

    public void verificarNombreUnico(Plantilla plantilla1) {
        plantillas.forEach(plantilla -> {
            if(plantilla.getNombre().trim().equals(plantilla1.getNombre().trim())){
                throw new IllegalArgumentException("Los nombres de las plantillas deben ser unicos");
            }
        });
        plantillas.add(plantilla1);
    }


    public List<Plantilla> buscarPorNombre(String nombreABuscar) {
        List<Plantilla> plantillasEncontradas = new ArrayList<>();
        plantillas.forEach(plantilla -> {
            if(plantilla.getNombre().contains(nombreABuscar)){
                plantillasEncontradas.add(plantilla);
            }
        });
        return plantillasEncontradas;
    }

    public List<Plantilla> buscarPorCategoriaGasto(CategoriaGasto categoriaGasto) {
        List<Plantilla> plantillasEncontradas = new ArrayList<>();
        plantillas.forEach(plantilla -> {
            if(plantilla.getCategoria().contains(categoriaGasto.toString())){
                plantillasEncontradas.add(plantilla);
            }
        });
        return plantillasEncontradas;
    }

    public List<Plantilla> buscarPorTipo(String tipo) {
        List<Plantilla> plantillasEncontradas = new ArrayList<>();
        plantillas.forEach(plantilla -> {
            if(plantilla.getTipo().contains(tipo)){
                plantillasEncontradas.add(plantilla);
            }
        });
        return plantillasEncontradas;
    }

    public void guardarEnLista(Plantilla plantilla) {
        plantillas.add(plantilla);
    }

    public List<Plantilla> buscarPlantillasConFiltros(Long id, String nombre, String tipo, String categoria) {
        return dao.buscarPorFiltros(id, nombre, tipo, categoria);
    }


}
