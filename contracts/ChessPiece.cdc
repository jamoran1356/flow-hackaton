// Declaración de contrato
contract Phelgaria {

    
// Definir un struct para representar una pieza de ajedrez
pub struct ChessPiece {
    pub nombre: String
    pub pieza: String
    pub set: u32
    pub experiencia: u32
    pub color: String
}

// Función para crear una pieza de ajedrez
pub fun crear_pieza(nombre: String, pieza: String, set: u32, experiencia: u32, color: String): ChessPiece {
    let pieza_ajedrez = ChessPiece {
        nombre: nombre,
        pieza: pieza,
        set: set,
        experiencia: experiencia,
        color: color,
    };
    
    // Crear el NFT para la pieza de ajedrez
    let nft_id = createNFT(pieza_ajedrez)
    
    return pieza_ajedrez;
}

// Función para crear un set completo de piezas de ajedrez (16 piezas)
pub fun crear_set(set: u32) {
    let piezas = ["peon", "caballo", "alfil", "torre", "rey", "reina"]
    let colores = ["blanco", "negro"]
    let experiencia = 0
    
    for i in 0..8 {
        let color = colores[i % 2]
        for j in 0..6 {
            let pieza = piezas[j]
            let nombre = format!("{} {}", color, pieza)
            
            crear_pieza(nombre, pieza, set, experiencia, color)
        }
    }
}

// Función para crear un paquete de piezas de ajedrez (4 piezas aleatorias)
pub fun crear_paquete(billetera_usuario: Address): [ChessPiece; 4] {
    let set = 1 // Solo hay un set por ahora
    let piezas = get_all_piezas(set)
    let num_piezas = piezas.length
    
    // Elegir 4 piezas aleatorias
    let paquete: [ChessPiece; 4]
    for i in 0..4 {
        let random_index = random(num_piezas)
        paquete[i] = piezas[random_index]
    }
    
    return paquete
}

// Función auxiliar para obtener todas las piezas de un set
pub fun get_all_piezas(set: u32): [ChessPiece] {
    let piezas: [ChessPiece]
    let nfts = getAllNFTs()
    for nft_id in nfts {
        let pieza = getNFT<nft_id, ChessPiece>()
        if pieza.set == set {
            piezas.append(pieza)
        }
    }
    
    return piezas
}

// Función para quemar una pieza de ajedrez y obtener experiencia
//contemplado no implementado
pub fun quemar_pieza(nft_id: UInt64) {
    let pieza = getNFT<nft_id, ChessPiece>()
    let experiencia_actual = pieza.experiencia
    
    if experiencia_actual > 0 {
        let experiencia_nueva = experiencia_actual - 1
        let pieza_modificada = ChessPiece {
            nombre: pieza.nombre,
            pieza: pieza.pieza,
            set: pieza.set,
            experiencia: experiencia_nueva,
            color: pieza.color,
        };
        
        // Actualizar la pieza de ajedrez
        updateNFT<nft_id, ChessPiece>(pieza_modificada)
        
        // Obtener una pieza de ajedrez nueva en base a la experiencia obtenida
        let nueva_pieza = obtener_pieza_por_experiencia(experiencia_actual)
        if nueva_pieza != null {
            crear_pieza(nueva_pieza.nombre, nueva_pieza.pieza, nueva_pieza.set, nueva_pieza.experiencia, nueva_pieza.color)
        }
    }
}

// Función para obtener una pieza de ajedrez nueva en base a la experiencia obtenida
pub fun obtener_pieza_por_experiencia(experiencia: u32): ChessPiece? {
    let piezas = [
        ChessPiece {
            nombre: "peon nuevo",
            pieza: "peon",
            set: 1,
            experiencia: experiencia,
            color: "blanco"
        },
        ChessPiece {
            nombre: "peon nuevo",
            pieza: "peon",
            set: 1,
            experiencia: experiencia,
            color: "negro"
        },
        ChessPiece {
            nombre: "torre nueva",
            pieza: "torre",
            set: 1,
            experiencia: experiencia,
            color: "blanco"
        },
        ChessPiece {
            nombre: "torre nueva",
            pieza: "torre",
            set: 1,
            experiencia: experiencia,
            color: "negro"
        },
        ChessPiece {
            nombre: "caballo nuevo",
            pieza: "caballo",
            set: 1,
            experiencia: experiencia,
            color: "blanco"
        },
        ChessPiece {
            nombre: "caballo nuevo",
            pieza: "caballo",
            set: 1,
            experiencia: experiencia,
            color: "negro"
        },
        ChessPiece {
            nombre: "alfil nuevo",
            pieza: "alfil",
            set: 1,
            experiencia: experiencia,
            color: "blanco"
        },
        ChessPiece {
            nombre: "alfil nuevo",
            pieza: "alfil",
            set: 1,
            experiencia: experiencia,
            color: "negro"
        },
        ChessPiece {
            nombre: "reina nueva",
            pieza: "reina",
            set: 1,
            experiencia: experiencia,
            color: "blanco"
        },
        ChessPiece {
            nombre: "reina nueva",
            pieza: "reina",
            set: 1,
            experiencia: experiencia,
            color: "negro"
        },
        ChessPiece {
            nombre: "rey nuevo",
            pieza: "rey",
            set: 1,
            experiencia: experiencia,
            color: "blanco"
        }]
}

// Función para quemar una pieza de ajedrez
pub fun quemar_pieza(nft_id: UInt64): bool {
    let pieza = getNFT<nft_id, ChessPiece>()
    
    // Verificar que la pieza pertenece al usuario que la quiere quemar
    assert(pieza.owner == getAccountAddress(), message = "No tienes autorización para quemar esta pieza.")
    
    // Eliminar la pieza
    destroyNFT(nft_id)
    
    // Verificar si se debe crear una nueva pieza
    let piezas = get_all_piezas(pieza.set)
    let num_piezas = piezas.length
    let num_piezas_burned = piezas_burned.get(pieza.set, 0)
    let num_piezas_created = piezas_created.get(pieza.set, 0)
    
    if num_piezas_burned >= 8 && num_piezas_created < 160000 {
        if num_piezas_burned % 8 == 0 {
            // Crear una torre
            let nombre = format!("{} torre", pieza.color)
            let torre = crear_pieza(nombre, "torre", pieza.set, 0, pieza.color)
            
            // Actualizar el contador de piezas creadas
            piezas_created.replace(pieza.set, num_piezas_created + 1)
        } else if (num_piezas_burned % 8) % 2 == 0 {
            // Crear un caballo
            let nombre = format!("{} caballo", pieza.color)
            let caballo = crear_pieza(nombre, "caballo", pieza.set, 0, pieza.color)
            
            // Actualizar el contador de piezas creadas
            piezas_created.replace(pieza.set, num_piezas_created + 1)
        } else {
            // Crear un alfil
            let nombre = format!("{} alfil", pieza.color)
            let alfil = crear_pieza(nombre, "alfil", pieza.set, 0, pieza.color)
            
            // Actualizar el contador de piezas creadas
            piezas_created.replace(pieza.set, num_piezas_created + 1)
        }
    }
    
    if num_piezas_burned >= 16 && num_piezas_created < 160000 {
        if num_piezas_burned % 16 == 0 {
            // Crear una reina
            let nombre = format!("{} reina", pieza.color)
            let reina = crear_pieza(nombre, "reina", pieza.set, 0, pieza.color)
            
            // Actualizar el contador de piezas creadas
            piezas_created.replace(pieza.set, num_piezas_created + 1)
        } else if (num_piezas_burned % 16) % 2 == 0 {
            // Crear un rey
            let nombre = format!("{} rey", pieza.color)
            let rey = crear_pieza(nombre, "rey", pieza.set, 0, pieza.color)
            
            // Actualizar el contador de piezas creadas
            piezas_created.replace(pieza.set, num_piezas_created + 1)
        }
    }
    
    // Actualizar el contador de piezas quemadas
    piezas_burned.replace(piezas.set, num_piezas_burned + 1) {
        return true
    }

pub fun buy_set(set: String, price: UFix64): {String: ChessPiece} {
    let account = getAccountAddress()
    let account_balance = getAccountBalance(account)
    
    // Verificar que el usuario tenga suficiente saldo para realizar la compra
    assert(account_balance >= price, message: "Saldo insuficiente para realizar la compra.")
    
    // Calcular la cantidad de piezas en el set
    let num_piezas = get_all_piezas(set).length
    
    // Verificar que el set tenga al menos 4 piezas
    assert(num_piezas >= 4, message: "El set no tiene suficientes piezas para realizar la compra.")
    
    // Crear un mapa para almacenar las piezas compradas
    var piezas_compradas: {String: ChessPiece} = {}
    
    // Seleccionar 4 piezas aleatorias del set
    var piezas_set = get_all_piezas(set)
    for i in 0...3 {
        let index = random(0, piezas_set.length - 1)
        piezas_compradas[piezas_set[index].name] = piezas_set[index]
        piezas_set.removeAt(index)
    }
    
    // Transferir el precio del set al nodo de staking
    let nodo_staking = getAccountAddress(address(0x01))
    let staking_balance = account_balance * 0.8
    transfer(account, nodo_staking, staking_balance)
    
    // Retornar las piezas compradas
    return piezas_compradas
}

pub fun transfer_to_staking(): UFix64 {
    let account = getAccountAddress()
    let account_balance = getAccountBalance(account)
    
    // Verificar que el usuario tenga suficiente saldo para realizar la transferencia
    assert(account_balance > 0, message: "Saldo insuficiente para realizar la transferencia.")
    
    // Transferir el 80% del saldo al nodo de staking
    let nodo_staking = getAccountAddress(address(0x01))
    let staking_balance = account_balance * 0.8
    transfer(account, nodo_staking, staking_balance)
    
    // Retornar el saldo transferido
    return staking_balance
}

pub fun sell_piece(pieza_id: UInt64, price: UFix64): bool {
let pieza = getNFT<pieza_id, ChessPiece>()
// Verificar que la pieza pertenece al usuario que la quiere vender
assert(pieza.owner == getAccountAddress(), message = "No tienes autorización para vender esta pieza.")

// Calcular el precio mínimo de venta
let set = pieza.set
let piezas_set = get_all_piezas(set)
let set_price = get_set_price(set)
let min_price = set_price / piezas_set.length

// Verificar que el precio de venta no sea menor al mínimo
assert(price >= min_price, message = "El precio de venta no puede ser menor al precio mínimo de venta.")

// Transferir la propiedad de la pieza al marketplace
transferNFT(pieza_id, getAccountAddress(MARKETPLACE))

// Registrar la venta en el registro de ventas
let venta = MarketplaceSale(
    seller: pieza.owner,
    buyer: nil,
    pieza_id: pieza_id,
    price: price,
    timestamp: getCurrentBlockTime()
)
let id = marketplace_sales.add(venta)

// Emitir un evento de venta
let event = MarketplaceEvent(
    type: "venta",
    pieza_id: pieza_id,
    set: set,
    price: price,
    seller: pieza.owner,
    buyer: nil,
    timestamp: getCurrentBlockTime()
)
emit(event)

return true

}


pub fun connect_curve_pool(): X {
  // Conectar a la pool de Curve
  // ...
  // Retornar la conexión establecida
}

pub fun create_portfolio(valor_usdc: UFix64, pieza_id: UInt64): X {
  let valor_staking = valor_usdc * 0.2
  staking_nodo_Phelgaria(pieza_id, getAccountAddress(), valor_staking)
  
  let pool_conn = connect_curve_pool()
  let portfolio = new Portfolio()
  
  // Obtener lista de pools en Curve
  let pools = pool_conn.getPools()
  
  // Obtener lista de tokens en el set
  let set = get_set_from_piece(pieza_id)
  let piezas_set = get_all_piezas(set)
  let tokens_set = piezas_set.map((pieza: ChessPiece) => pieza.token)
  
  // Obtener lista de tokens con buen rendimiento
  let best_tokens = []
  for pool in pools {
    let token = pool.getBestToken(tokens_set)
    if token != nil {
      best_tokens.append(token)
    }
  }
  
  // Calcular montos a invertir
  let total_value = valor_usdc * 0.8
  let values = calculate_values(total_value, best_tokens)
  
  // Invertir en los tokens seleccionados
  for i in 0..best_tokens.length {
    let token = best_tokens[i]
    let value = values[i]
    let nft_token = new NFTToken(token)
    let investment = new Investment(nft_token, value)
    portfolio.addInvestment(investment)
  }
  
  // Retornar el portfolio
  return portfolio
}

pub fun get_portfolio(pieza_id: UInt64): Portfolio {
  // Obtener el portfolio del usuario que posee la pieza
  let user = get_owner_of_piece(pieza_id)
  let portfolio = get_portfolio_of_user(user)
  return portfolio
}

pub fun staking_en_Phelgaria(pieza_id: UInt64, valor_usdc: UFix64): Bool {
    let valor_staking = valor_usdc * 0.2
    
    // Realizar el staking en el nodo de Phelgaria
    let staking_exitoso = staking_nodo_Phelgaria(pieza_id, getAccountAddress(), valor_staking)
    
    // Verificar que el staking haya sido exitoso
    assert(staking_exitoso, message: "Error al realizar el staking en el nodo de Phelgaria.")
    
    // Conectarse a la pool de Curve
    let pool = getPool(0x....)
    
    // Calcular la cantidad de USDC a invertir en Defis
    let cantidad_defis = valor_usdc * 0.8
    
    // Crear un portfolio invirtiendo en Defis con buen retorno
    let portfolio = crear_portfolio(pool, cantidad_defis)
    
    // Enviar los resultados de las inversiones a la billetera del usuario
    Billetera_nfts.enviar_resultados(portfolio)
    
    return true
        }
    }
}