<template>
  <div class="modcoprop">
    <div class="content-modcoprop">
      <div class="field">
        <div class="control">
          <form @submit.prevent.once="selCoprop" autocomplete="off">
            <div class="field is-horizontal">
              <div class="field-label is-normal">
                <label class="label"
                  >Seleccione la copropiedad a modificar</label
                >
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <div class="select is-fullwidth">
                      <select v-model="copropSeleccionada">
                        <option
                          v-for="coprop in coprops"
                          :value="coprop"
                          v-bind:key="coprop.id"
                        >
                          {{ coprop.nombre }}
                        </option>
                      </select>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="field">
              <div class="control">
                <button class="button is-link is-fullwidth">Modificar</button>
              </div>
            </div>
          </form>
        </div>
      </div>
      <div class="field" v-show="seleccionado">
        <div class="control">
          <form @submit.prevent.once="modCoprop" name="form">
            <div class="field is-horizontal">
              <div class="field-label is-normal">
                <label class="label">Nombre</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <input
                      type="text"
                      class="input"
                      v-model="copropSeleccionada.nombre"
                    />
                  </div>
                </div>
              </div>
            </div>
            <div class="field is-horizontal">
              <div class="field-label is-normal">
                <label class="label">Direccion</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <input
                      type="text"
                      class="input"
                      v-model="copropSeleccionada.direccion"
                    />
                  </div>
                </div>
              </div>
            </div>
            <div class="field is-horizontal">
              <div class="field-label is-normal">
                <label class="label">Habilitada</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <div class="select is-fullwidth">
                      <select v-model="habilitada">
                        <option>Si</option>
                        <option>No</option>
                      </select>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="field is-horizontal" v-if="habilitada === 'Si'">
              <div class="field-label is-normal">
                <label class="label">Seleccione el usuario administrador</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <div class="select is-fullwidth">
                      <select v-model="usuarioSeleccionado">
                        <option
                          v-for="usuario in usuarios"
                          :value="usuario"
                          v-bind:key="usuario.identificacion"
                        >
                          {{ usuario.nombres }} {{ usuario.apellidos }}
                        </option>
                      </select>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="field">
              <div class="control">
                <button class="button is-link is-fullwidth">Modificar</button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import jsonInfo from "../../assets/info.json";
export default {
  name: "ModCoprop",
  data() {
    return {
      mssg: "Copropiedad/Conjunto residencial modificado con exito",
      coprops: [],
      copropSeleccionada: {},
      seleccionado: false,
      habilitada: "Si",
      usuarios: [],
      usuarioSeleccionado: {},
    };
  },
  methods: {
    loadCoprops() {
      var url = jsonInfo.url_server + jsonInfo.name_app + "/globals/select.php";
      this.seleccionado = false;
      this.copropSeleccionada = {};
      this.coprops = [];
      var requestObject = {
        tabla: "copropiedad",
      };
      this.$axios
        .get(url, { params: requestObject })
        .then((response) => {
          this.coprops = response.data;
        })
        .catch((e) => {
          console.log(e);
          this.error = true;
        });
    },
    selCoprop() {
      this.seleccionado = true;
      this.loadUsers();
    },
    modCoprop() {
      var url = jsonInfo.url_server + jsonInfo.name_app + "/globals/update.php";
      this.copropSeleccionada.tabla = "copropiedad";
      this.copropSeleccionada.nombre = this.copropSeleccionada.nombre.toUpperCase();
      this.copropSeleccionada.direccion = this.copropSeleccionada.direccion.toUpperCase();
      this.copropSeleccionada.habilitada = this.habilitada === "Si" ? "1" : "0";
      this.copropSeleccionada.id_administrador = this.usuarioSeleccionado.id;
      this.$axios
        .post(url, this.copropSeleccionada)
        .then((response) => {
          if (response.data == true) alert(this.mssg);
          this.loadCoprops();
        })
        .catch((e) => {
          console.log(e);
          this.error = true;
        });
      this.seleccionado = false;
    },
    loadUsers() {
      var url = jsonInfo.url_server + jsonInfo.name_app + "/globals/select.php";
      this.usuarios = [];
      var requestObject = {
        tabla: "usuario",
        tipo_usuario: "A",
      };
      this.$axios
        .get(url, { params: requestObject })
        .then((response) => {
          this.usuarios = response.data;
        })
        .catch((e) => {
          console.log(e);
          this.error = true;
        });
    },
  },
  beforeCreate() {
    this.$bus.$emit("checkSession", "");
  },
  created() {
    this.loadCoprops();
  },
};
</script>
<style>
</style>