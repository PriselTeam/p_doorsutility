local oSQLQuery = sql.Query

function sql.Query(query)
    sql.m_strError = nil

    return oSQLQuery(query)
end