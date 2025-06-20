@REQ_TEST_SEMESTRAL @HU_SEMESTRAL @marvel_characters @marvel_characters_api @Agente2 @E2 @iniciativa_api_testing
Feature: TEST_SEMESTRAL API de Personajes Marvel (microservicio para gestión de personajes de Marvel)

  Background:
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser'
    * header Content-Type = 'application/json'
    * configure ssl = true

  @id:1 @obtener_todos_personajes @solicitudExitosa200
  Scenario: T-API-TEST_SEMESTRAL-CA01-Obtener todos los personajes exitosamente 200 - karate
    Given path '/api/characters'
    When method GET
    Then status 200
    And match response == '#array'
    And match each response contains { id: '#number', name: '#string' }
    * def schema = { id: '#number', name: '#string', alterego: '#string', description: '#string', powers: '#array' }
    And match each response == schema

  @id:2 @obtener_personaje_por_id @solicitudExitosa200
  Scenario: T-API-TEST_SEMESTRAL-CA02-Creación, Actualización, Eliminación y Obtención personaje Estados:201,200,204,400,404 - karate
    # Primero creamos un personaje para luego consultarlo
    Given path '/api/characters'
    And request read('classpath:data/marvel_characters_api/request_create_character.json')
    When method POST
    Then status 201
    * def characterId = response.id
    And match response.id == characterId
    And match response.name == 'Anderson Vivas Test'
    And match response.alterego == 'Tony Stark'
    And match response.powers contains 'Armor'
    And match response.powers contains 'Flight'

    # Ahora consultamos el personaje creado
    Given path '/api/characters/' + characterId
    When method GET
    Then status 200
    And match response.name == 'Anderson Vivas Test'
    And match response.alterego == 'Tony Stark'
    And match response.powers contains 'Armor'
    And match response.powers contains 'Flight'

     # Intentamos crear otro personaje con el mismo nombre
    Given path '/api/characters'
    And request read('classpath:data/marvel_characters_api/request_create_character.json')
    When method POST
    Then status 400
    And match response.error == 'Character name already exists'
    And match response contains { error: '#string' }
    # Actualizamos el Personaje
      Given path '/api/characters/' + characterId
    And request read('classpath:data/marvel_characters_api/request_update_character.json')
    When method PUT
    Then status 200
    And match response.description == 'Updated description'
    And match response.powers contains 'Intelligence'
    And match response.powers contains 'Armor'
    And match response.powers contains 'Flight'

    # Eliminamos el personaje
    Given path '/api/characters/' + characterId
    When method DELETE
    Then status 204

    # Verificamos que el personaje ya no existe
    Given path '/api/characters/' + characterId
    When method GET
    Then status 404
    And match response.error == '#string'
    And match response contains { error: 'Character not found' }





  @id:6 @crear_personaje_invalido @solicitudErrorCamposInvalidos400
  Scenario: T-API-TEST_SEMESTRAL-CA06-Crear personaje con campos inválidos 400 - karate
    Given path '/api/characters'
    And request read('classpath:data/marvel_characters_api/request_invalid_character.json')
    When method POST
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'
    And match response.powers == 'Powers are required'



  @id:8 @actualizar_personaje_no_existente @solicitudNoEncontrado404
  Scenario: T-API-TEST_SEMESTRAL-CA08-Actualizar personaje no existente 404 - karate
    Given path '/api/characters/999'
    And request read('classpath:data/marvel_characters_api/request_update_character.json')
    When method PUT
    Then status 404
    And match response.error == 'Character not found'
    And match response contains { error: '#string' }



  @id:11 @error_servidor_interno @solicitudErrorServidor500
  Scenario: T-API-TEST_SEMESTRAL-CA11-Error interno del servidor 500 - karate
    # Escenario simula un error 500 mediante una ruta inválida
    Given path '/api/invalid-operation'
    When method POST
    Then status 500
    And match response.error == '#string'
    And match response contains { error: '#present' }