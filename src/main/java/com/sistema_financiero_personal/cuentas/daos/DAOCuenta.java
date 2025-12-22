package com.sistema_financiero_personal.cuentas.daos;

import com.sistema_financiero_personal.comun.DAOBase;
import com.sistema_financiero_personal.cuentas.modelos.Cuenta;
import com.sistema_financiero_personal.cuentas.modelos.TipoCuenta;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Root;

import java.util.List;

public class DAOCuenta extends DAOBase<Cuenta> {

    public DAOCuenta() {super(Cuenta.class);}

    public List<Cuenta> listarPorCartera(Long idCartera) {
        return buscarPorCampo("cartera.id", idCartera);
    }
    public boolean existeCuentaPorNombreYTipo(String nombre, TipoCuenta tipo, Long idCartera) {
        return executeQuery(session -> {
            CriteriaBuilder cb = session.getCriteriaBuilder();
            CriteriaQuery<Long> cq = cb.createQuery(Long.class);
            Root<Cuenta> root = cq.from(Cuenta.class);

            Expression<String> nombreNormalizado = cb.lower(
                    cb.trim(root.get("nombre"))
            );

            String nombreBuscar = nombre.trim().toLowerCase();

            cq.select(cb.count(root))
                    .where(
                            cb.and(
                                    cb.equal(nombreNormalizado, nombreBuscar),
                                    cb.equal(root.get("tipo"), tipo),
                                    cb.equal(root.get("cartera").get("id"), idCartera)
                            )
                    );

            Long count = session.createQuery(cq).getSingleResult();
            return count > 0;
        });
    }

    public boolean existe(Long id) {
        return executeQuery(session -> session.createQuery(
                        "select count(cu) > 0 from Cuenta cu where cu.id = :id",
                        Boolean.class
                ).setParameter("id", id)
                .getSingleResult());
    }

    public double obtenerMonto(Long cuentaId) {
        return executeQuery(session -> {
            Double monto = session.createQuery(
                            "select cu.monto from Cuenta cu where cu.id = :id",
                            Double.class
                    ).setParameter("id", cuentaId)
                    .uniqueResult();
            return monto != null ? monto : 0.0;
        });
    }

}
